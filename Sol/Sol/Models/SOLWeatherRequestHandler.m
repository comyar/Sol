//
//  SOLWeatherRequestHandler.m
//  Sol
//
//  Created by Comyar Zaheri on 10/24/14.
//  Copyright (c) 2014 Comyar Zaheri. All rights reserved.
//


#pragma mark - Imports

#import "SOLWeatherRequestHandler.h"
#import "SOLKeyReader.h"
#import "SOLWeatherViewModel.h"


#pragma mark - SOLWeatherDataCache Interface

/**
 */
@interface SOLWeatherDataCache : NSObject

// -----
// @name Using the Weather Data Cache
// -----

/**
 */
+ (SOLWeatherData *)weatherDataForPlacemark:(CLPlacemark *)placemark;

/**
 */
+ (void)setWeatherData:(SOLWeatherData *)weatherData forPlacemark:(CLPlacemark *)placemark;

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
                    
                    
                    completion(weatherData);
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

+ (void)weatherDataForRequest:(CLPlacemark *)placemark
               withCompletion:(SOLWeatherRequestHandlerCompletion)completion
{
    SOLWeatherData *weatherData = [SOLWeatherDataCache weatherDataForPlacemark:placemark];
    if (weatherData) {
        completion(weatherData);
    } else {
        [SOLWeatherDataDownloader weatherDataForPlacemark:placemark withCompletion: ^ (SOLWeatherData *weatherData) {
            [SOLWeatherDataCache setWeatherData:weatherData forPlacemark:placemark];
            completion(weatherData);
        }];
    }
}

@end
