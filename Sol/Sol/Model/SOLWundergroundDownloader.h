//
//  SOLWundergroundDownloader.h
//  Sol
//
//  Created by Comyar Zaheri on 8/7/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

@class SOLWeatherData;

//  Block Definition
typedef void (^SOLWeatherDataDownloadCompletion)(SOLWeatherData *data, NSError *error);

/**
 SOLWundergroundDownloader is a singleton object that queries the Wunderground Weather API and downloads weather
 data for a given location.
 */
@interface SOLWundergroundDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>


// -----
// @name Initializing a Wunderground Downloader
// -----

/**
 Returns a shared instance of SOLWundergroundDownloader
 @returns A shared instance of SOLWundergroundDownloader
 */
+ (SOLWundergroundDownloader *)sharedDownloader;


// -----
// @name Using a Wunderground Downloader
// -----

/**
 Queries the Wunderground Weather API and downloads weather data for the given location
 @param location    Location to download weather data for
 @param tag         Tag of the weather view expecting to receive the downloaded weather data
 @param completion  Block that returns a SOLWeatherData object on success, and nil on failure
 */
- (void)dataForLocation:(CLLocation *)location withTag:(NSInteger)tag completion:(SOLWeatherDataDownloadCompletion)completion;

/**
 Queries the Wunderground Weather API and downloads weather data for the given location
 @param placemark   Placemark to download weather data for
 @param tag         Tag of the weather view expecting to receive the downloaded weather data
 @param completion  Block that returns a SOLWeatherData object on success, and nil on failure
 */
- (void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSInteger)tag completion:(SOLWeatherDataDownloadCompletion)completion;

@end
