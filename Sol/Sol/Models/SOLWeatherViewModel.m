//
//  SOLWeatherViewModel.m
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

#import "SOLWeatherViewModel.h"


#pragma mark - Constants

// Minimum number of forecast conditions to create a valid SOLWeatherViewModel
static const NSUInteger minNumForecastConditions    = 4;

// Number of seconds in a day
static const NSTimeInterval dayLength               = 86400.0;


#pragma mark - SOLWeatherViewModel Class Extension

@interface SOLWeatherViewModel ()

@property (nonatomic) NSString *conditionIconString;
@property (nonatomic) NSString *conditionLabelString;
@property (nonatomic) NSString *locationLabelString;
@property (nonatomic) NSString *currentTemperatureLabelString;
@property (nonatomic) NSString *highLowTemperatureLabelString;
@property (nonatomic) NSString *forecastDayOneLabelString;
@property (nonatomic) NSString *forecastIconOneLabelString;
@property (nonatomic) NSString *forecastDayTwoLabelString;
@property (nonatomic) NSString *forecastIconTwoLabelString;
@property (nonatomic) NSString *forecastDayThreeLabelString;
@property (nonatomic) NSString *forecastIconThreeLabelString;

@end


#pragma mark - SOLWeatherViewModel Implementation

@implementation SOLWeatherViewModel

+ (SOLWeatherViewModel *)weatherViewModelForPlacemark:(CLPlacemark *)placemark
                              currentWeatherCondition:(CZWeatherCondition *)currentWeatherCondition
                            forecastWeatherConditions:(NSArray *)forecastWeatherConditions
                                              celsius:(BOOL)celsius
{
    return [[SOLWeatherViewModel alloc]initWithPlacemark:placemark
                                 currentWeatherCondition:currentWeatherCondition
                               forecastWeatherConditions:forecastWeatherConditions
                                                 celsius:celsius];
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
          currentWeatherCondition:(CZWeatherCondition *)currentWeatherCondition
        forecastWeatherConditions:(NSArray *)forecastWeatherConditions
                          celsius:(BOOL)celsius
{
    if (self = [super init]) {
        self.conditionLabelString = currentWeatherCondition.summary;
        self.conditionIconString = [NSString stringWithFormat:@"%c", currentWeatherCondition.climaconCharacter];
        self.locationLabelString = [NSString stringWithFormat:@"%@, %@", placemark.locality,
                                    [placemark.country isEqualToString:@"United States"]? placemark.administrativeArea : placemark.country];
        
        CZWeatherCondition *todayForecastCondition = [forecastWeatherConditions firstObject];
        CGFloat todayCurrentTemperature         = (celsius)? currentWeatherCondition.temperature.c : currentWeatherCondition.temperature.f;
        CGFloat todayForecastHighTemperature    = (celsius)? todayForecastCondition.highTemperature.c : todayForecastCondition.highTemperature.f;
        CGFloat todayForecastLowTemperature     = (celsius)? todayForecastCondition.lowTemperature.c : todayForecastCondition.lowTemperature.f;
        self.currentTemperatureLabelString = [NSString stringWithFormat:@"%.0f°", todayCurrentTemperature];
        
        self.highLowTemperatureLabelString = [NSString stringWithFormat:@"H %.0f / L %.0f",
                                              todayForecastHighTemperature,
                                              todayForecastLowTemperature];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEE";
        
        self.forecastDayOneLabelString      = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1.0 * dayLength]];
        self.forecastDayTwoLabelString      = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2.0 * dayLength]];
        self.forecastDayThreeLabelString    = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3.0 * dayLength]];
        
        CZWeatherCondition *dayOneForecastCondition     = forecastWeatherConditions[1];
        CZWeatherCondition *dayTwoForecastCondition     = forecastWeatherConditions[2];
        CZWeatherCondition *dayThreeForecastCondition   = forecastWeatherConditions[3];
        
        self.forecastIconOneLabelString   = [NSString stringWithFormat:@"%c", dayOneForecastCondition.climaconCharacter];
        self.forecastIconTwoLabelString   = [NSString stringWithFormat:@"%c", dayTwoForecastCondition.climaconCharacter];
        self.forecastIconThreeLabelString = [NSString stringWithFormat:@"%c", dayThreeForecastCondition.climaconCharacter];
    }
    return self;
}

+ (BOOL)validPlacemark:(CLPlacemark *)placemark
{
    return placemark.locality && (placemark.administrativeArea || placemark.country);
}

+ (BOOL)validCurrentWeatherCondition:(CZWeatherCondition *)currentWeatherCondition
{
    return  currentWeatherCondition.summary                                 &&
            currentWeatherCondition.temperature.f != CZWeatherKitNoValue    &&
            currentWeatherCondition.temperature.c != CZWeatherKitNoValue;
}

+ (BOOL)validForecastWeatherConditions:(NSArray *)forecastWeatherConditions
{
    BOOL valid = NO;
    
    for (CZWeatherCondition *forecastCondition in forecastWeatherConditions) {
        valid = forecastCondition.highTemperature.c != CZWeatherKitNoValue  &&
                forecastCondition.highTemperature.f != CZWeatherKitNoValue  &&
                forecastCondition.lowTemperature.c  != CZWeatherKitNoValue  &&
                forecastCondition.lowTemperature.f  != CZWeatherKitNoValue  &&
                forecastCondition.summary;
        if (!valid) {
            return valid;
        }
    }
    
    valid = [forecastWeatherConditions count] >= minNumForecastConditions;
    
    return valid;
}

@end
