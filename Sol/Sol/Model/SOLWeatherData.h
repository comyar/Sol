//
//  SOLWeatherData.h
//  Sol
//
//  Created by Comyar Zaheri on 8/3/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

typedef struct {
    CGFloat fahrenheit;
    CGFloat celsius;
} SOLTemperature;

static inline SOLTemperature SOLTemperatureMake(CGFloat fahrenheit, CGFloat celsius) {
    return (SOLTemperature){fahrenheit, celsius};
}

#pragma mark - SOLWeatherSnapshot Interface

/**
 SOLWeatherSnapshot contains weather data for a single day
 */
@interface SOLWeatherSnapshot : NSObject <NSCoding>

// -----
// @name Properties
// -----

//  Icon representing the day's conditions
@property (strong, nonatomic) NSString      *icon;

//  Name of the day of week
@property (strong, nonatomic) NSString      *dayOfWeek;

//  Description of the day's conditions
@property (strong, nonatomic) NSString      *conditionDescription;

//  Day's current temperature, if applicable
@property (assign, nonatomic) SOLTemperature currentTemperature;

//  Day's high temperature
@property (assign, nonatomic) SOLTemperature highTemperature;

//  Day's low temperature
@property (assign, nonatomic) SOLTemperature lowTemperature;

@end


#pragma mark - SOLWeatherData Interface

/**
 SOLWeatherData contains comprehensive multi-day weather data for a given location
 */
@interface SOLWeatherData : NSObject <NSCoding>

// -----
// @name Properties
// -----

//  Location whose weather data is being represented
@property (strong, nonatomic) CLPlacemark            *placemark;

//  Snapshot of the current conditions
@property (strong, nonatomic) SOLWeatherSnapshot    *currentSnapshot;

//  Snapshots of forecasted conditions
@property (strong, nonatomic) NSMutableArray        *forecastSnapshots;

//  Time when this object was created
@property (strong, nonatomic) NSDate                *timestamp;

@end
