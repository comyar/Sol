//
//  SOLWeatherRequestHandler.m
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
//


#pragma mark - Imports

#import "SOLWeatherRequestHandler.h"
#import "SOLKeyReader.h"
#import "SOLWeatherViewModel.h"


#pragma mark - Constants

static const NSTimeInterval kDefaultFreshness = 3600;


#pragma mark - SOLWeatherData Interface

/**
 */
@interface SOLWeatherData : NSObject <NSCoding>

// -----
// @name Creating a Weather Data
// -----

#pragma mark Creating a Weather Data

/**
 */
+ (SOLWeatherData *)weatherDataForWeatherViewModel:(SOLWeatherViewModel *)weatherViewModel
                                         timestamp:(NSDate *)timestamp;

// -----
// @name Properties
// -----

#pragma mark Properties

//
@property (nonatomic) SOLWeatherViewModel     *weatherViewModel;

//
@property (nonatomic) NSDate                  *timestamp;

@end


#pragma mark - SOLWeatherData Implementation

@implementation SOLWeatherData

#pragma mark Creating a Weather Data

+ (SOLWeatherData *)weatherDataForWeatherViewModel:(SOLWeatherViewModel *)weatherViewModel
                                         timestamp:(NSDate *)timestamp
{
    SOLWeatherData *weatherData = [SOLWeatherData new];
    weatherData.weatherViewModel = weatherViewModel;
    weatherData.timestamp = timestamp;
    return weatherData;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.weatherViewModel = [aDecoder decodeObjectForKey:@"weatherViewModel"];
        self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.weatherViewModel forKey:@"weatherViewModel"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
}

@end


#pragma mark - SOLWeatherDataCache Interface

/**
 */
@interface SOLWeatherDataCache : NSObject

// -----
// @name Using the Weather Data Cache
// -----

#pragma mark Using the Weather Data Cache

/**
 */
+ (SOLWeatherViewModel *)weatherViewModelForPlacemark:(CLPlacemark *)placemark freshness:(NSTimeInterval)freshness;

/**
 */
+ (void)setWeatherViewModel:(SOLWeatherViewModel *)weatherViewModel forPlacemark:(CLPlacemark *)placemark;

@end


#pragma mark - SOLWeatherDataCache Implementation

@implementation SOLWeatherDataCache

+ (SOLWeatherViewModel *)weatherViewModelForPlacemark:(CLPlacemark *)placemark freshness:(NSTimeInterval)freshness
{
    if (placemark) {
        NSString *key = [NSString stringWithFormat:@"%ld", placemark.hash];
        NSData *archivedData = [[NSUserDefaults standardUserDefaults]objectForKey:key];
        if (archivedData) {
            SOLWeatherData *weatherData = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
            if ([weatherData.timestamp timeIntervalSinceNow] > -freshness) {
                return weatherData.weatherViewModel;
            }
        }
    }
    return nil;
}

+ (void)setWeatherViewModel:(SOLWeatherViewModel *)weatherViewModel forPlacemark:(CLPlacemark *)placemark
{
    if (placemark && weatherViewModel) {
        SOLWeatherData *weatherData = [SOLWeatherData weatherDataForWeatherViewModel:weatherViewModel
                                                                           timestamp:[NSDate date]];
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:weatherData];
        [[NSUserDefaults standardUserDefaults]setObject:archivedData forKey:[NSString stringWithFormat:@"%ld", placemark.hash]];
    }
}

@end


#pragma mark - SOLWeatherDataDownloader Interface

/**
 */
@interface SOLWeatherDataDownloader : NSObject

// -----
// @name Using the Weather Data Downloader
// -----

/**
 */
+ (void)weatherDataForPlacemark:(CLPlacemark *)placemark withCompletion:(SOLWeatherRequestHandlerCompletion)completion;

@end


#pragma mark - SOLWeatherDataDownloader Implementation

@implementation SOLWeatherDataDownloader

+ (void)weatherDataForPlacemark:(CLPlacemark *)placemark withCompletion:(SOLWeatherRequestHandlerCompletion)completion
{
    if (!placemark) {
        completion(nil);
    }
    
    CZWeatherRequest *currentConditionRequest   = [CZWeatherRequest requestWithType:CZCurrentConditionsRequestType];
    currentConditionRequest.location            = [CZWeatherLocation locationWithCLLocationCoordinate2D:placemark.location.coordinate];
    currentConditionRequest.service             = [CZWundergroundService serviceWithKey:[SOLKeyReader keyForDictionaryKey:WundergroundKeyName]];
    
    CZWeatherRequest *forecastConditionsRequest = [CZWeatherRequest requestWithType:CZForecastRequestType];
    forecastConditionsRequest.location          = [CZWeatherLocation locationWithCLLocationCoordinate2D:placemark.location.coordinate];
    forecastConditionsRequest.service           = [CZWundergroundService serviceWithKey:[SOLKeyReader keyForDictionaryKey:WundergroundKeyName]];
    
    [currentConditionRequest performRequestWithHandler: ^ (id data, NSError *error) {
        if (data) {
            __block CZWeatherCondition *currentCondition = (CZWeatherCondition *)data;
            [forecastConditionsRequest performRequestWithHandler: ^ (id data, NSError *error) {
                if (data) {
                    NSArray *forecastConditions = (NSArray *)data;
                    SOLWeatherViewModel *weatherViewModel = [SOLWeatherViewModel weatherViewModelForPlacemark:placemark currentCondition:currentCondition forecastConditions:forecastConditions];
                    completion(weatherViewModel);
                } else {
                    completion(nil);
                }
            }];
        } else {
            completion(nil);
        }
    }];
}

@end


#pragma mark - SOLWeatherRequestHandler Implementation

@implementation SOLWeatherRequestHandler

+ (void)weatherViewModelForRequest:(CLPlacemark *)placemark
               completion:(SOLWeatherRequestHandlerCompletion)completion
{
    [SOLWeatherRequestHandler weatherViewModelForRequest:placemark freshness:kDefaultFreshness completion:completion];
}

+ (void)weatherViewModelForRequest:(CLPlacemark *)placemark
                    freshness:(NSTimeInterval)freshness
               completion:(SOLWeatherRequestHandlerCompletion)completion
{
    SOLWeatherViewModel *weatherViewModel = [SOLWeatherDataCache weatherViewModelForPlacemark:placemark freshness:freshness];
    if (weatherViewModel) {
        completion(weatherViewModel);
    } else {
        [SOLWeatherDataDownloader weatherDataForPlacemark:placemark withCompletion: ^ (SOLWeatherViewModel *weatherViewModel) {
            [SOLWeatherDataCache setWeatherViewModel:weatherViewModel forPlacemark:placemark];
            completion(weatherViewModel);
        }];
    }
}

@end
