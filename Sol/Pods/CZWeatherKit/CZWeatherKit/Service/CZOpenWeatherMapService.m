//
//  CZOpenWeatherMapService.m
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
#import "CZOpenWeatherMapService.h"
#import "CZWeatherCondition.h"
#import "CZWeatherRequest.h"


#pragma mark - Macros

#if !(TARGET_OS_IPHONE)
#define CGPointValue pointValue
#endif


#pragma mark - Constants

// Base URL
static NSString * const base        = @"http://api.openweathermap.org/data/2.5/";

// Name of the service
static NSString * const serviceName = @"Open Weather Map";


#pragma mark - Macros

#define F_TO_C(temp) (5.0/9.0) * (temp - 32.0)
#define MPH_TO_KPH(speed) (speed * 1.609344)


#pragma mark - CZOpenWeatherMapService Implementation

@implementation CZOpenWeatherMapService
@synthesize key = _key, serviceName = _serviceName;

#pragma mark Creating a Weather Service

- (instancetype)init
{
    return [self initWithKey:nil];
}

- (instancetype)initWithKey:(NSString *)key
{
    if (self = [super init]) {
        _key = key;
        _serviceName = serviceName;
    }
    return self;
}

+ (instancetype)serviceWithKey:(NSString *)key
{
    return [[CZOpenWeatherMapService alloc]initWithKey:key];
}

#pragma mark Using a Weather Service

- (NSURL *)urlForRequest:(CZWeatherRequest *)request
{
    NSString *url = base;
    
    if (request.requestType == CZCurrentConditionsRequestType) {
        url = [url stringByAppendingString:@"weather?"];
    } else if (request.requestType == CZForecastRequestType && request.detailLevel == CZWeatherRequestLightDetail) {
        url = [url stringByAppendingString:@"forecast/hourly?"];
    } else if (request.requestType == CZForecastRequestType && request.detailLevel == CZWeatherRequestFullDetail) {
        url = [url stringByAppendingString:@"forecast/daily?"];
    }
    
    if (request.location.locationType == CZWeatherLocationCoordinateType) {
        CGPoint coordinate = [request.location.locationData[CZWeatherLocationCoordinateName]CGPointValue];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"lat=%.4f&lon=%.4f", coordinate.x, coordinate.y]];
    } else if (request.location.locationType == CZWeatherLocationCityStateType) {
        NSString *city = request.location.locationData[CZWeatherLocationCityName];
        city = [city stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *state = request.location.locationData[CZWeatherLocationStateName];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"q=%@,%@", city, state]];
    } else if (request.location.locationType == CZWeatherLocationCityCountryType) {
        NSString *city = request.location.locationData[CZWeatherLocationCityName];
        city = [city stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *country = request.location.locationData[CZWeatherLocationCountryName];
        country = [country stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"q=%@,%@", city, country]];
    } else {
        return nil;
    }
    
    url = [url stringByAppendingString:@"&mode=json&units=imperial"];
    
    if ([self.key length] > 0) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&appid=%@", self.key]];
    }
    
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
        return [self parseForecastFromJSON:JSON forDetailLevel:request.detailLevel];
    }
    
    return nil;
}

#pragma mark Helper

- (CZWeatherCondition *)parseCurrentConditionsFromJSON:(NSDictionary *)JSON
{
    CZWeatherCondition *condition = [CZWeatherCondition new];
    
    CGFloat tempF = [JSON[@"main"][@"temp"]floatValue];
    condition.temperature = (CZTemperature){tempF, F_TO_C(tempF)};
    
    CGFloat highTempF = [JSON[@"main"][@"temp_max"]floatValue];
    condition.highTemperature = (CZTemperature){highTempF, F_TO_C(highTempF)};
    
    CGFloat lowTempF = [JSON[@"main"][@"temp_min"]floatValue];
    condition.lowTemperature = (CZTemperature){lowTempF, F_TO_C(lowTempF)};
    
    condition.humidity = [JSON[@"main"][@"humidity"]floatValue];
    condition.description = [JSON[@"weather"]firstObject][@"description"];
    condition.climaconCharacter = [self climaconCharacterForDescription:condition.description];
    
    CGFloat windSpeedMPH = [JSON[@"wind"][@"speed"]floatValue];
    condition.windSpeed = (CZWindSpeed){windSpeedMPH, MPH_TO_KPH(windSpeedMPH)};
    condition.windDegrees = [JSON[@"wind"][@"deg"]floatValue];
    
    condition.date = [NSDate dateWithTimeIntervalSince1970:[JSON[@"dt"]doubleValue]];
    
    return condition;
}

- (NSArray *)parseForecastFromJSON:(NSDictionary *)JSON forDetailLevel:(CZWeatherRequestDetailLevel)detailLevel
{
    NSMutableArray *forecastConditions = [NSMutableArray new];
    
    NSArray *forecasts = JSON[@"list"];
    
    for (NSDictionary *forecast in forecasts) {
        CZWeatherCondition *condition = [CZWeatherCondition new];
        
        if (detailLevel == CZWeatherRequestLightDetail) {
            CGFloat highTempF = [forecast[@"main"][@"temp_max"]floatValue];
            condition.highTemperature = (CZTemperature){highTempF, F_TO_C(highTempF)};
            
            CGFloat lowTempF = [forecast[@"main"][@"temp_min"]floatValue];
            condition.lowTemperature = (CZTemperature){lowTempF, F_TO_C(lowTempF)};
            
            condition.humidity = [forecast[@"main"][@"humidity"]floatValue];
            
            CGFloat windSpeedMPH = [forecast[@"wind"][@"speed"]floatValue];
            condition.windSpeed = (CZWindSpeed){windSpeedMPH, MPH_TO_KPH(windSpeedMPH)};
            
            condition.windDegrees = [forecast[@"wind"][@"deg"]floatValue];

        } else if (detailLevel == CZWeatherRequestFullDetail) {
            CGFloat highTempF = [forecast[@"temp"][@"max"]floatValue];
            condition.highTemperature = (CZTemperature){highTempF, F_TO_C(highTempF)};
            
            CGFloat lowTempF = [forecast[@"temp"][@"min"]floatValue];
            condition.lowTemperature = (CZTemperature){lowTempF, F_TO_C(lowTempF)};
            
            condition.humidity = [forecast[@"humidity"]floatValue];
            
            CGFloat windSpeedMPH = [forecast[@"speed"]floatValue];
            condition.windSpeed = (CZWindSpeed){windSpeedMPH, MPH_TO_KPH(windSpeedMPH)};
            
            condition.windDegrees = [forecast[@"deg"]floatValue];
        }
        
        condition.description = [forecast[@"weather"]firstObject][@"description"];
        
        condition.date = [NSDate dateWithTimeIntervalSince1970:[forecast[@"dt"]doubleValue]];
        
        condition.climaconCharacter = [self climaconCharacterForDescription:condition.description];
        
        [forecastConditions addObject:condition];
    }
    
    return [forecastConditions copy];
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
