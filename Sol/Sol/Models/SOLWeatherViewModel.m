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

@property (nonatomic) NSString *currentTemperatureCelsiusString;
@property (nonatomic) NSString *currentTemperatureFahrenheitString;
@property (nonatomic) NSString *highLowTemperatureCelsiusString;
@property (nonatomic) NSString *highLowTemperatureFahrenheitString;

@end


#pragma mark - SOLWeatherViewModel Implementation

@implementation SOLWeatherViewModel

+ (SOLWeatherViewModel *)weatherViewModelForPlacemark:(CLPlacemark *)placemark
                                     currentCondition:(CZWeatherCondition *)currentCondition
                                   forecastConditions:(NSArray *)forecastConditions
{
    return [SOLWeatherViewModel weatherViewModelForPlacemark:placemark
                                            currentCondition:currentCondition
                                          forecastConditions:forecastConditions
                                             temperatureMode:SOLFahrenheitMode];
}

+ (SOLWeatherViewModel *)weatherViewModelForPlacemark:(CLPlacemark *)placemark
                                     currentCondition:(CZWeatherCondition *)currentCondition
                                   forecastConditions:(NSArray *)forecastConditions
                                      temperatureMode:(SOLWeatherViewTemperatureMode)temperatureMode
{
    if (!placemark || !currentCondition || [forecastConditions count] == 0) {
        return nil;
    }
    
    return [[SOLWeatherViewModel alloc]initWithPlacemark:placemark
                                        currentCondition:(CZWeatherCondition *)currentCondition
                                      forecastConditions:(NSArray *)forecastConditions
                                         temperatureMode:temperatureMode];
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
                 currentCondition:(CZWeatherCondition *)currentCondition
               forecastConditions:(NSArray *)forecastConditions
                  temperatureMode:(SOLWeatherViewTemperatureMode)temperatureMode
{
    if (self = [super init]) {
        
        self.temperatureMode = temperatureMode;
        
        self.conditionLabelString = currentCondition.summary;
        self.conditionIconString = [NSString stringWithFormat:@"%c", currentCondition.climaconCharacter];
        self.locationLabelString = [NSString stringWithFormat:@"%@, %@", placemark.locality,
                                    [placemark.country isEqualToString:@"United States"]? placemark.administrativeArea : placemark.country];
        
        self.currentTemperatureCelsiusString = [NSString stringWithFormat:@"%.0f°", currentCondition.temperature.c];
        
        CZWeatherCondition *todayForecastCondition = [forecastConditions firstObject];
        self.currentTemperatureFahrenheitString = [NSString stringWithFormat:@"%.0f°", currentCondition.temperature.f];
        self.highLowTemperatureCelsiusString = [NSString stringWithFormat:@"H %.0f / L %.0f",
                                                todayForecastCondition.highTemperature.c,
                                                todayForecastCondition.lowTemperature.c];
        self.highLowTemperatureFahrenheitString  = [NSString stringWithFormat:@"H %.0f / L %.0f",
                                                    todayForecastCondition.highTemperature.f,
                                                    todayForecastCondition.lowTemperature.f];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEE";
        
        self.forecastDayOneLabelString      = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:1.0 * dayLength]];
        self.forecastDayTwoLabelString      = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:2.0 * dayLength]];
        self.forecastDayThreeLabelString    = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3.0 * dayLength]];
        
        CZWeatherCondition *dayOneForecastCondition     = forecastConditions[1];
        CZWeatherCondition *dayTwoForecastCondition     = forecastConditions[2];
        CZWeatherCondition *dayThreeForecastCondition   = forecastConditions[3];
        
        self.forecastIconOneLabelString   = [NSString stringWithFormat:@"%c", dayOneForecastCondition.climaconCharacter];
        self.forecastIconTwoLabelString   = [NSString stringWithFormat:@"%c", dayTwoForecastCondition.climaconCharacter];
        self.forecastIconThreeLabelString = [NSString stringWithFormat:@"%c", dayThreeForecastCondition.climaconCharacter];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.conditionIconString                = [aDecoder decodeObjectForKey:@"conditionIconString"];
        self.conditionLabelString               = [aDecoder decodeObjectForKey:@"conditionLabelString"];
        self.locationLabelString                = [aDecoder decodeObjectForKey:@"locationLabelString"];
        self.currentTemperatureLabelString      = [aDecoder decodeObjectForKey:@"currentTemperatureLabelString"];
        self.highLowTemperatureLabelString      = [aDecoder decodeObjectForKey:@"highLowTemperatureLabelString"];
        self.forecastDayOneLabelString          = [aDecoder decodeObjectForKey:@"forecastDayOneLabelString"];
        self.forecastIconOneLabelString         = [aDecoder decodeObjectForKey:@"forecastIconOneLabelString"];
        self.forecastDayTwoLabelString          = [aDecoder decodeObjectForKey:@"forecastDayTwoLabelString"];
        self.forecastIconTwoLabelString         = [aDecoder decodeObjectForKey:@"forecastIconTwoLabelString"];
        self.forecastDayThreeLabelString        = [aDecoder decodeObjectForKey:@"forecastDayThreeLabelString"];
        self.forecastIconThreeLabelString       = [aDecoder decodeObjectForKey:@"forecastIconThreeLabelString"];
        
        self.currentTemperatureCelsiusString    = [aDecoder decodeObjectForKey:@"currentTemperatureCelsiusString"];
        self.currentTemperatureFahrenheitString = [aDecoder decodeObjectForKey:@"currentTemperatureFahrenheitString"];
        self.highLowTemperatureCelsiusString    = [aDecoder decodeObjectForKey:@"highLowTemperatureCelsiusString"];
        self.highLowTemperatureFahrenheitString = [aDecoder decodeObjectForKey:@"highLowTemperatureFahrenheitString"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.conditionIconString forKey:@"conditionIconString"];
    [aCoder encodeObject:self.conditionLabelString forKey:@"conditionLabelString"];
    [aCoder encodeObject:self.locationLabelString forKey:@"locationLabelString"];
    [aCoder encodeObject:self.currentTemperatureLabelString forKey:@"currentTemperatureLabelString"];
    [aCoder encodeObject:self.highLowTemperatureLabelString forKey:@"highLowTemperatureLabelString"];
    [aCoder encodeObject:self.forecastDayOneLabelString forKey:@"forecastDayOneLabelString"];
    [aCoder encodeObject:self.forecastIconOneLabelString forKey:@"forecastIconOneLabelString"];
    [aCoder encodeObject:self.forecastDayTwoLabelString forKey:@"forecastDayTwoLabelString"];
    [aCoder encodeObject:self.forecastIconTwoLabelString forKey:@"forecastIconTwoLabelString"];
    [aCoder encodeObject:self.forecastDayThreeLabelString forKey:@"forecastDayThreeLabelString"];
    [aCoder encodeObject:self.forecastIconThreeLabelString forKey:@"forecastIconThreeLabelString"];

    [aCoder encodeObject:self.currentTemperatureCelsiusString forKey:@"currentTemperatureCelsiusString"];
    [aCoder encodeObject:self.currentTemperatureFahrenheitString forKey:@"currentTemperatureFahrenheitString"];
    [aCoder encodeObject:self.highLowTemperatureCelsiusString forKey:@"highLowTemperatureCelsiusString"];
    [aCoder encodeObject:self.highLowTemperatureFahrenheitString forKey:@"highLowTemperatureFahrenheitString"];
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

#pragma mark Getter Methods

- (NSString *)currentTemperatureLabelString
{
    if (self.temperatureMode == SOLCelsiusMode) {
        return self.currentTemperatureCelsiusString;
    }
    return self.currentTemperatureFahrenheitString;
}

- (NSString *)highLowTemperatureLabelString
{
    if (self.temperatureMode == SOLCelsiusMode) {
        return self.highLowTemperatureCelsiusString;
    }
    return self.highLowTemperatureFahrenheitString;
}

@end
