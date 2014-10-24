//
//  SOLWeatherRequestHandler.h
//  Sol
//
//  Created by Comyar Zaheri on 10/24/14.
//  Copyright (c) 2014 Comyar Zaheri. All rights reserved.
//


#pragma mark - Imports

@import Foundation;
#import <CZWeatherKit/CZWeatherRequest.h>


#pragma mark - Forward Declarations

@class SOLWeatherData;


#pragma mark - Type Definitions

typedef void (^SOLWeatherRequestHandlerCompletion)(SOLWeatherData *weatherData);


#pragma mark - SOLWeatherRequestHandler Interface

@interface SOLWeatherRequestHandler : NSObject

// -----
// @name Using Weather Request Handler
// -----

/**
 */
+ (void)weatherDataForRequest:(CLPlacemark *)placemark
               withCompletion:(SOLWeatherRequestHandlerCompletion)completion;

@end
