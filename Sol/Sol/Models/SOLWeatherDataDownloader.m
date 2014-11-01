//
//  SOLWeatherDataDownloader.m
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

#import "SOLWeatherDataDownloader.h"
#import "SOLWeatherViewModel.h"
#import "SOLKeyReader.h"


#pragma mark - SOLWeatherDataDownloader Implementation

@implementation SOLWeatherDataDownloader

+ (void)weatherDataForPlacemark:(CLPlacemark *)placemark withCompletion:(SOLWeatherDataDownloaderCompletion)completion
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
