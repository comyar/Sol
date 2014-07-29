//
//  CZWeatherCondition.m
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

#import "CZWeatherCondition.h"


#pragma mark - CZWeatherCondition Class Extension

@interface CZWeatherCondition ()

// Date of the weather conditions represented.
@property (nonatomic) NSDate            *date;

// Word or phrase describing the conditions.
@property (nonatomic) NSString          *summary;

// Climacon character that matches the condition description.
@property (nonatomic) Climacon          climaconCharacter;

// Predicted low temperature.
@property (nonatomic) CZTemperature     lowTemperature;

// Predicted high temperature.
@property (nonatomic) CZTemperature     highTemperature;

// Current temperature.
@property (nonatomic) CZTemperature     temperature;

// Relative humidity.
@property (nonatomic) CGFloat           humidity;

// Wind direction in degrees.
@property (nonatomic) CGFloat           windDegrees;

// Wind speed.
@property (nonatomic) CZWindSpeed       windSpeed;

@end


#pragma mark - CZWeatherCondition Implementation

@implementation CZWeatherCondition

#pragma mark Creating a Weather Condition

- (instancetype)init
{
    if (self = [super init]) {
        self.lowTemperature     = (CZTemperature){CZWeatherKitNoValue, CZWeatherKitNoValue};
        self.highTemperature    = (CZTemperature){CZWeatherKitNoValue, CZWeatherKitNoValue};
        self.temperature        = (CZTemperature){CZWeatherKitNoValue, CZWeatherKitNoValue};
    }
    return self;
}

#pragma mark NSCoding Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.date               = [aDecoder decodeObjectForKey:@"date"];
        self.summary            = [aDecoder decodeObjectForKey:@"summary"];
        self.climaconCharacter  = [aDecoder decodeIntForKey:@"climaconCharacter"];
        self.lowTemperature     = (CZTemperature){[aDecoder decodeFloatForKey:@"lowTemperature_f"],
                                                  [aDecoder decodeFloatForKey:@"lowTemperature_c"]};
        self.highTemperature    = (CZTemperature){[aDecoder decodeFloatForKey:@"highTemperature_f"],
                                                  [aDecoder decodeFloatForKey:@"highTemperature_c"]};
        self.temperature        = (CZTemperature){[aDecoder decodeFloatForKey:@"temperature_f"],
                                                  [aDecoder decodeFloatForKey:@"temperature_c"]};
        self.humidity           = [aDecoder decodeFloatForKey:@"humidity"];
        self.windDegrees        = [aDecoder decodeFloatForKey:@"windDegrees"];
        self.windSpeed          = (CZWindSpeed){[aDecoder decodeFloatForKey:@"windSpeed_mph"],
                                                [aDecoder decodeFloatForKey:@"windSpeed_kph"]};
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date              forKey:@"date"];
    [aCoder encodeObject:self.summary           forKey:@"summary"];
    [aCoder encodeInt:self.climaconCharacter    forKey:@"climaconCharacter"];
    [aCoder encodeFloat:self.lowTemperature.f   forKey:@"lowTemperature_f"];
    [aCoder encodeFloat:self.lowTemperature.c   forKey:@"lowTemperature_c"];
    [aCoder encodeFloat:self.highTemperature.f  forKey:@"highTemperature_f"];
    [aCoder encodeFloat:self.highTemperature.c  forKey:@"highTemperature_c"];
    [aCoder encodeFloat:self.temperature.f      forKey:@"temperature_f"];
    [aCoder encodeFloat:self.temperature.c      forKey:@"temperature_c"];
    [aCoder encodeFloat:self.humidity           forKey:@"humidity"];
    [aCoder encodeFloat:self.windDegrees        forKey:@"windDegrees"];
    [aCoder encodeFloat:self.windSpeed.mph      forKey:@"windSpeed_mph"];
    [aCoder encodeFloat:self.windSpeed.kph      forKey:@"windSpeed_kph"];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class]alloc]init];
    
    if (copy) {
        [copy setDate:[self.date copyWithZone:zone]];
        [copy setSummary:[self.summary copyWithZone:zone]];
        [copy setClimaconCharacter:self.climaconCharacter];
        [copy setLowTemperature:self.lowTemperature];
        [copy setHighTemperature:self.highTemperature];
        [copy setTemperature:self.temperature];
        [copy setHumidity:self.humidity];
        [copy setWindDegrees:self.windDegrees];
        [copy setWindSpeed:self.windSpeed];
    }
    
    return copy;
}

@end
