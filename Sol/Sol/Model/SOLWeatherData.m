//
//  SOLWeatherData.m
//  Sol
//
//  Created by Comyar Zaheri on 8/3/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLWeatherData.h"

static const NSInteger _num_forecast_snapshots = 3;

#pragma mark - SOLWeatherSnapshot Implementation

@implementation SOLWeatherSnapshot

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if(self = [super init]) {
        self.icon = [coder decodeObjectForKey:@"icon"];
        self.dayOfWeek = [coder decodeObjectForKey:@"day_of_week"];
        self.conditionDescription = [coder decodeObjectForKey:@"condition_description"];
        self.currentTemperature = SOLTemperatureMake([coder decodeFloatForKey:@"c_temp_f"], [coder decodeFloatForKey:@"c_temp_c"]);
        self.highTemperature = SOLTemperatureMake([coder decodeFloatForKey:@"h_temp_f"], [coder decodeFloatForKey:@"h_temp_c"]);
        self.lowTemperature = SOLTemperatureMake([coder decodeFloatForKey:@"l_temp_f"], [coder decodeFloatForKey:@"l_temp_c"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.icon forKey:@"icon"];
    [coder encodeObject:self.dayOfWeek forKey:@"day_of_week"];
    [coder encodeObject:self.conditionDescription forKey:@"condition_description"];
    [coder encodeFloat:self.currentTemperature.fahrenheit forKey:@"c_temp_f"];
    [coder encodeFloat:self.currentTemperature.celsius forKey:@"c_temp_c"];
    [coder encodeFloat:self.highTemperature.fahrenheit forKey:@"h_temp_f"];
    [coder encodeFloat:self.highTemperature.celsius forKey:@"h_temp_c"];
    [coder encodeFloat:self.lowTemperature.fahrenheit forKey:@"l_temp_f"];
    [coder encodeFloat:self.lowTemperature.celsius forKey:@"l_temp_c"];
}

@end

#pragma mark -SOLWeatherData Implementation

@implementation SOLWeatherData

- (instancetype)init
{
    if(self = [super init]) {
        self.currentSnapshot = [[SOLWeatherSnapshot alloc]init];
        self.forecastSnapshots = [[NSMutableArray alloc]initWithCapacity:3];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if(self = [super init]) {
        self.placemark = [coder decodeObjectForKey:@"placemark"];
        self.timestamp = [coder decodeObjectForKey:@"timestamp"];
        self.currentSnapshot = [coder decodeObjectForKey:@"current_snapshot"];
        
        self.forecastSnapshots = [[NSMutableArray alloc]initWithCapacity:5];
        for(int i = 0; i < _num_forecast_snapshots; ++i) {
            NSString *key = [NSString stringWithFormat:@"forecast_snapshot%d", i];
            SOLWeatherSnapshot *snapshot = [coder decodeObjectForKey:key];
            if(snapshot) {
                [self.forecastSnapshots addObject:snapshot];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.placemark forKey:@"placemark"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.currentSnapshot forKey:@"current_snapshot"];
    
    NSInteger count = [self.forecastSnapshots count];
    for(int i = 0; i < count; ++i) {
        NSString *key = [NSString stringWithFormat:@"forecast_snapshot%d", i];
        [coder encodeObject:[self.forecastSnapshots objectAtIndex:i]  forKey:key];
    }
}

@end
