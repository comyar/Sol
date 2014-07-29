//
//  CZWeatherCondition.h
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

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#endif

#import "Climacons.h"


#pragma mark - Type Definitions

/**
 Temperature struct.
 */
typedef struct {
    /** Fahrenheit */
    CGFloat f;
    /** Celsius */
    CGFloat c;
} CZTemperature;

/**
 Wind struct.
 */
typedef struct {
    /** Miles per hour */
    CGFloat mph;
    /** Kilometers per hour */
    CGFloat kph;
} CZWindSpeed;

/**
 Special values
 */
typedef NS_ENUM(NSInteger, CZWeatherKitValue) {
    /** Indicates no value is available */
    CZWeatherKitNoValue = NSIntegerMin
};


#pragma mark - CZWeatherCondition Interface

/**
 CZWeatherCondition represents the weather conditions at a particular time. This may be the current time or some
 time at a future date. 
 
 For example, a CZWeatherCondition object may be used to represent the current weather conditions as well as
 forecasted weather condtions at a later date.
 */
@interface CZWeatherCondition : NSObject <NSCoding, NSCopying>

// -----
// @name Properties
// -----

#pragma mark Properties

/**
 Date of the weather conditions represented.
 
 The exact time of day and timezone is dependent on the specifc weather service's API. 
 However, it's (probably, hopefully...) safe to assume the month, day, and year are correct.
 */
@property (nonatomic, readonly) NSDate          *date;

/**
 Word or phrase describing the conditions. 
 
 (e.g. 'Clear', 'Rain', etc.) The possible words/phrases are defined by each weather
 service's API.
 */
@property (nonatomic, readonly) NSString        *summary;

/**
 Climacon character that matches the condition description.
 */
@property (nonatomic, readonly) Climacon        climaconCharacter;

/**
 Predicted low temperature.
 
 If no values are available, each member of the struct will be equal to CZWeatherKitNoValue.
 */
@property (nonatomic, readonly) CZTemperature   lowTemperature;

/**
 Predicted high temperature.
 
 If no values are available, each member of the struct will be equal to CZWeatherKitNoValue.
 */
@property (nonatomic, readonly) CZTemperature   highTemperature;

/**
 Current temperature.
 
 If no values are available, each member of the struct will be equal to CZWeatherKitNoValue.
 */
@property (nonatomic, readonly) CZTemperature   temperature;

/**
 Relative humidity.
 */
@property (nonatomic, readonly) CGFloat         humidity;

/**
 Wind direction in degrees.
 */
@property (nonatomic, readonly) CGFloat         windDegrees;

/**
 Wind speed.
 */
@property (nonatomic, readonly) CZWindSpeed     windSpeed;

@end
