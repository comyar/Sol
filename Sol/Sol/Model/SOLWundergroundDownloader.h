//
//  SOLWundergroundDownloader.h
//  Sol
//
//  Created by Comyar Zaheri on 8/7/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//


@class SOLWeatherData;

@protocol SOLWundergroundDownloaderDelegate <NSObject>

/**
 Called by a SOLWundergroundDownloader when downloading weather data for the given location failed. 
 This may occur for a few reasons, such as the user having no internet connection, invalid API key, or invalid location.
 @param location    Location that weather data was unable to be downloaded for
 @param tag         Tag of the weather view that expected to receive the downloaded weather data
 */
- (void)downloadDidFailForLocation:(CLLocation *)location withTag:(NSInteger)tag;

/**
 Called by a SOLWundergroundDownloader when downloading weather data for the given location completed.
 @param location    Location that weather data was downloaded for
 @param tag         Tag of the weather view expecting to receive the downloaded weather data
 */
- (void)downloadDidFinishWithData:(SOLWeatherData *)data withTag:(NSInteger)tag;

@end

/**
 SOLWundergroundDownloader is a singleton object that queries the Wunderground Weather API and downloads weather
 data for a given location.
 */
@interface SOLWundergroundDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/////////////////////////////////////////////////////////////////////////////
/// @name Initializing a Wunderground Downloader
/////////////////////////////////////////////////////////////////////////////

/**
 Returns a shared instance of SOLWundergroundDownloader
 @returns A shared instance of SOLWundergroundDownloader
 */
+ (SOLWundergroundDownloader *)sharedDownloader;


/////////////////////////////////////////////////////////////////////////////
/// @name Using a Wunderground Downloader
/////////////////////////////////////////////////////////////////////////////

/**
 Queries the Wunderground Weather API and downloads weather data for the given location
 @param location    Location to download weather data for
 @param tag         Tag of the weather view expecting to receive the downloaded weather data
 @param delegate    Object implementing the SOLWundergroundDownloaderDelegate protocal to report downloads to
 */
- (void)dataForLocation:(CLLocation *)location withTag:(NSInteger)tag delegate:(id<SOLWundergroundDownloaderDelegate>)delegate;

/**
 Queries the Wunderground Weather API and downloads weather data for the given location
 @param placemark   Placemark to download weather data for
 @param tag         Tag of the weather view expecting to receive the downloaded weather data
 @param delegate    Object implementing the SOLWundergroundDownloaderDelegate protocal to report downloads to
 */
- (void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSInteger)tag delegate:(id<SOLWundergroundDownloaderDelegate>)delegate;

@end
