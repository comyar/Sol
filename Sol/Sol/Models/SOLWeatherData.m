//
//  SOLWeatherData.m
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

#import "SOLWeatherData.h"


#pragma mark - SOLWeatherData Class Extension

@interface SOLWeatherData ()

@property (nonatomic) SOLWeatherViewModel     *weatherViewModel;
@property (nonatomic) CLPlacemark             *placemark;
@property (nonatomic) NSDate                  *timestamp;

@end


#pragma mark - SOLWeatherData Implementation

@implementation SOLWeatherData

+ (SOLWeatherData *)weatherDataForWeatherViewModel:(SOLWeatherViewModel *)weatherViewModel
                                         placemark:(CLPlacemark *)placemark
                                         timestamp:(NSDate *)timestamp
{
    SOLWeatherData *weatherData = [SOLWeatherData new];
    weatherData.weatherViewModel = weatherViewModel;
    weatherData.placemark = placemark;
    weatherData.timestamp = timestamp;
    return weatherData;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.weatherViewModel = [aDecoder decodeObjectForKey:@"weatherViewModel"];
        self.placemark = [aDecoder decodeObjectForKey:@"placemark"];
        self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.weatherViewModel forKey:@"weatherViewModel"];
    [aCoder encodeObject:self.placemark forKey:@"placemark"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
}

@end
