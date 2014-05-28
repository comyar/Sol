//
//  CZWundergroundService.m
//  Copyright (c) 2014, Comyar Zaheri, http://comyar.io
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#pragma mark - Imports

#import "NSString+CZWeatherKit_Substring.h"
#import "CZWeatherService_Internal.h"
#import "CZWundergroundService.h"
#import "CZWeatherCondition.h"
#import "CZWeatherRequest.h"


#pragma mark - Macros

#if !(TARGET_OS_IPHONE)
#define CGPointValue pointValue
#endif


#pragma mark - Constants

// Base URL
static NSString * const base        = @"http://api.wunderground.com/api";

// Name of the service
static NSString * const serviceName = @"Weather Underground";


#pragma mark - CZWundergroundService Implementation

@implementation CZWundergroundService
@synthesize key = _key, serviceName = _serviceName;

#pragma mark Creating a Weather Service

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key
{
    if (self = [super init]) {
        _key            = key;
        _serviceName    = serviceName;
    }
    return self;
}

+ (instancetype)serviceWithKey:(NSString *)key
{
    return [[CZWundergroundService alloc]initWithKey:key];
}

#pragma mark Using a Weather Service

- (NSURL *)urlForRequest:(CZWeatherRequest *)request
{
    if ([self.key length] == 0) {
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/", base, self.key];
    
    if (request.requestType == CZCurrentConditionsRequestType) {
        url = [url stringByAppendingString:@"conditions/"];
    }else if (request.requestType == CZForecastRequestType && request.detailLevel == CZWeatherRequestLightDetail) {
        url = [url stringByAppendingString:@"forecast/"];
    } else if (request.requestType == CZForecastRequestType && request.detailLevel == CZWeatherRequestFullDetail) {
        url = [url stringByAppendingString:@"forecast10day/"];
    }
    
    url = [url stringByAppendingString:@"q/"];
    
    if (request.location.locationType == CZWeatherLocationCoordinateType) {
        CGPoint coordinate = [request.location.locationData[CZWeatherLocationCoordinateName]CGPointValue];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%.4f,%.4f", coordinate.x, coordinate.y]];
    } else if (request.location.locationType == CZWeatherLocationZipcodeType) {
        url = [url stringByAppendingString:request.location.locationData[CZWeatherLocationZipcodeName]];
    } else if (request.location.locationType == CZWeatherLocationAutoIPType) {
        url = [url stringByAppendingString:@"autoip"];
    } else if (request.location.locationType == CZWeatherLocationCityStateType) {
        NSString *city = request.location.locationData[CZWeatherLocationCityName];
        city = [city stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *state = request.location.locationData[CZWeatherLocationStateName];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@/%@", state, city]];
    } else if (request.location.locationType == CZWeatherLocationCityCountryType) {
        NSString *city = request.location.locationData[CZWeatherLocationCityName];
        city = [city stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *country = request.location.locationData[CZWeatherLocationCountryName];
        country = [country stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@/%@", country, city]];
    } else {
        return nil;
    }
    
    url = [url stringByAppendingString:@".json"];
    
    return [NSURL URLWithString:url];
}

- (id)weatherDataForResponseData:(NSData *)data request:(CZWeatherRequest *)request
{
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    if (!JSON) {
        return nil;
    }
    
    if (request.requestType == CZCurrentConditionsRequestType) {
        return [self parseCurrentConditionsFromJSON:JSON];
    } else if (request.requestType == CZForecastRequestType) {
        return [self parseForecastFromJSON:JSON];
    }
    
    return nil;
}

#pragma mark Helper

- (CZWeatherCondition *)parseCurrentConditionsFromJSON:(NSDictionary *)JSON
{
    CZWeatherCondition *condition = [CZWeatherCondition new];
    
    NSDictionary *currentObservation = JSON[@"current_observation"];
    
    NSTimeInterval epoch = [currentObservation[@"observation_epoch"]doubleValue];
    condition.date = [NSDate dateWithTimeIntervalSince1970:epoch];
    condition.description = currentObservation[@"weather"];
    condition.climaconCharacter = [self climaconCharacterForDescription:condition.description];
    condition.temperature = (CZTemperature){[currentObservation[@"temp_f"]floatValue], [currentObservation[@"temp_c"]floatValue]};
    condition.windDegrees = [currentObservation[@"wind_degrees"]floatValue];
    condition.windSpeed = (CZWindSpeed){[currentObservation[@"wind_mph"]floatValue],[currentObservation[@"wind_kph"]floatValue]};
    condition.humidity = [[currentObservation[@"relative_humidity"]stringByReplacingOccurrencesOfString:@"%" withString:@""]floatValue];
    
    return condition;
}

- (NSArray *)parseForecastFromJSON:(NSDictionary *)JSON
{
    NSMutableArray *forecasts = [NSMutableArray new];
    
    NSArray *forecastDay = JSON[@"forecast"][@"simpleforecast"][@"forecastday"];
    
    for (NSDictionary *day in forecastDay) {
        CZWeatherCondition *condition = [CZWeatherCondition new];
        
        NSTimeInterval epoch = [day[@"date"][@"epoch"]doubleValue];
        condition.date = [NSDate dateWithTimeIntervalSince1970:epoch];
        condition.description = day[@"conditions"];
        condition.highTemperature = (CZTemperature){[day[@"high"][@"fahrenheit"]floatValue], [day[@"high"][@"celsius"]floatValue]};
        condition.lowTemperature = (CZTemperature){[day[@"low"][@"fahrenheit"]floatValue], [day[@"low"][@"celsius"]floatValue]};
        condition.climaconCharacter = [self climaconCharacterForDescription:condition.description];
        condition.humidity = [day[@"avehumidity"]floatValue];
        condition.windSpeed = (CZWindSpeed){[day[@"avewind"][@"mph"]floatValue], [day[@"avewind"][@"kph"]floatValue]};
        condition.windDegrees = [day[@"avewind"][@"degrees"]floatValue];
        [forecasts addObject:condition];
    }
    
    return [forecasts copy];
}

- (Climacon)climaconCharacterForDescription:(NSString *)description
{
    Climacon icon = ClimaconSun;
    NSString *lowercaseDescription = [description lowercaseString];
    
    if([lowercaseDescription contains:@"clear"]) {
        icon = ClimaconSun;
    } else if([lowercaseDescription contains:@"cloud"]) {
        icon = ClimaconCloud;
    } else if([lowercaseDescription contains:@"drizzle"]  ||
              [lowercaseDescription contains:@"rain"]     ||
              [lowercaseDescription contains:@"thunderstorm"]) {
        icon = ClimaconRain;
    } else if([lowercaseDescription contains:@"snow"]     ||
              [lowercaseDescription contains:@"hail"]     ||
              [lowercaseDescription contains:@"ice"]) {
        icon = ClimaconSnow;
    } else if([lowercaseDescription contains:@"fog"]      ||
              [lowercaseDescription contains:@"overcast"] ||
              [lowercaseDescription contains:@"smoke"]    ||
              [lowercaseDescription contains:@"dust"]     ||
              [lowercaseDescription contains:@"ash"]      ||
              [lowercaseDescription contains:@"mist"]     ||
              [lowercaseDescription contains:@"haze"]     ||
              [lowercaseDescription contains:@"spray"]    ||
              [lowercaseDescription contains:@"squall"]) {
        icon = ClimaconHaze;
    }
    return icon;
}

@end
