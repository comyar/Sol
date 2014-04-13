//
//  SOLStateManager.h
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOLWeatherData;

typedef enum {
    SOLFahrenheitScale = 0,
    SOLCelsiusScale
} SOLTemperatureScale;

/**
 SOLStateManager allows for easy state persistence and acts as a thin wrapper around NSUserDefaults
 */
@interface SOLStateManager : NSObject

// -----
// @name Using the State Manager
// -----

/**
 Get the saved temperature scale
 @returns The saved temperature scale
 */
+ (SOLTemperatureScale)temperatureScale;

/**
 Save the given temperature scale
 @param scale Temperature scale to save
 */
+ (void)setTemperatureScale:(SOLTemperatureScale)scale;

/**
 Get saved weather data
 @returns Saved weather data as a dictionary
 */
+ (NSDictionary *)weatherData;

/**
 Save the given weather data
 @param weatherData Weather data to save
 */
+ (void)setWeatherData:(NSDictionary *)weatherData;

/**
 Get the saved ordered-list of weather tags
 @returns The saved weather tags
 */
+ (NSArray *)weatherTags;

/**
 Save the given ordered-list of weather tags
 @param weatherTags List of weather tags
 */
+ (void)setWeatherTags:(NSArray *)weatherTags;

@end
