//
//  SOLWeatherViewModel.m
//  Copyright (c) 2014 Comyar Zaheri, http://comyar.io
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#pragma mark - Imports

#import "SOLWeatherViewModel.h"


#pragma mark - Constants

// Minimum number of forecast conditions to create a valid SOLWeatherViewModel
static const NSUInteger minNumForecastConditions    = 4;

// Number of seconds in a day
static const NSTimeInterval dayLength               = 86400.0;


#pragma mark - SOLWeatherViewModel Class Extension

@interface SOLWeatherViewModel ()

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
    if ([SOLWeatherViewModel validCurrentWeatherCondition:currentWeatherCondition]     &&
        [SOLWeatherViewModel validForecastWeatherConditions:forecastWeatherConditions] &&
        [SOLWeatherViewModel validPlacemark:placemark]) {
        return [[SOLWeatherViewModel alloc]initWithPlacemark:placemark
                                     currentWeatherCondition:currentWeatherCondition
                                   forecastWeatherConditions:forecastWeatherConditions
                                                     celsius:celsius];
    }
    return nil;
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
          currentWeatherCondition:(CZWeatherCondition *)currentWeatherCondition
        forecastWeatherConditions:(NSArray *)forecastWeatherConditions
                          celsius:(BOOL)celsius
{
    if (self = [super init]) {
        self.conditionLabelString = currentWeatherCondition.description;
        self.locationLabelString = [NSString stringWithFormat:@"%@, %@", placemark.locality,
                                    [placemark.ISOcountryCode isEqualToString:@"US"]? placemark.administrativeArea : placemark.country];
        
        CZWeatherCondition *todayForecastCondition = [forecastWeatherConditions firstObject];
        CGFloat todayCurrentTemperature         = (celsius)? todayForecastCondition.temperature.c : todayForecastCondition.temperature.f;
        CGFloat todayForecastHighTemperature    = (celsius)? todayForecastCondition.highTemperature.c : todayForecastCondition.highTemperature.f;
        CGFloat todayForecastLowTemperature     = (celsius)? todayForecastCondition.lowTemperature.c : todayForecastCondition.lowTemperature.f;
        self.currentTemperatureLabelString = [NSString stringWithFormat:@"%.0f°", todayCurrentTemperature];
        self.highLowTemperatureLabelString = [NSString stringWithFormat:@"%.0f/%.0f", todayForecastHighTemperature, todayForecastLowTemperature];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEE";
        
        self.forecastDayOneLabelString      = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1.0 * dayLength]];
        self.forecastDayTwoLabelString      = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2.0 * dayLength]];
        self.forecastDayThreeLabelString    = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3.0 * dayLength]];
        
        CZWeatherCondition *dayOneForecastCondition     = forecastWeatherConditions[1];
        CZWeatherCondition *dayTwoForecastCondition     = forecastWeatherConditions[2];
        CZWeatherCondition *dayThreeForecastCondition   = forecastWeatherConditions[3];
        
        self.forecastIconOneLabelString = [NSString stringWithFormat:@"%c",     dayOneForecastCondition.climaconCharacter];
        self.forecastIconTwoLabelString = [NSString stringWithFormat:@"%c",     dayTwoForecastCondition.climaconCharacter];
        self.forecastIconThreeLabelString = [NSString stringWithFormat:@"%c",   dayThreeForecastCondition.climaconCharacter];
    }
    return self;
}

+ (BOOL)validPlacemark:(CLPlacemark *)placemark
{
    return placemark.locality && (placemark.administrativeArea || placemark.country);
}

+ (BOOL)validCurrentWeatherCondition:(CZWeatherCondition *)currentWeatherCondition
{
    return  currentWeatherCondition.description                             &&
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
                forecastCondition.description;
        if (!valid) {
            return valid;
        }
    }
    
    valid = [forecastWeatherConditions count] >= minNumForecastConditions;
    
    return valid;
}

@end
