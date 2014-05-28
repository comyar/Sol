//
//  CZWeatherService.h
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

@import Foundation;


#pragma mark - Forward Declarations

@class CZWeatherRequest;


#pragma mark - Protocol

/**
 The CZWeatherService protocol outlines an interface for objects to implement in order to act
 as services for weather requests. Objects adopting the CZWeatherService protocol provide URLs
 for specific weather APIs and parse downloaded data.
 */
@protocol CZWeatherService <NSObject>

@required

// -----
// @name Creating a Weather Service
// -----

#pragma mark Creating a Weather Service

/**
 Creates and returns a weather service with the given key.
 @param key API key to use for the given service.
 @return A newly created weather service.
 */
+ (instancetype)serviceWithKey:(NSString *)key;

/**
 Initializes a newly allocated weather service.
 @param key API key to use for the given service.
 @return A newly initialized weather service.
 */
- (instancetype)initWithKey:(NSString *)key;

// -----
// @name Using a Weather Service
// -----

#pragma mark Using a Weather Service

/**
 Returns the appropriate URL for the given request.
 @param request Weather requests asking for the URL.
 @return URL for the given request, or nil if the request is malformed.
 */
- (NSURL *)urlForRequest:(CZWeatherRequest *)request;

/**
 Parses the response data from the given request.
 @param data    Response data from a weather request.
 @param request Weather request that retrieved the response data.
 @return Weather data instance from the parsed response data, or nil if the data is malformed.
 */
- (id)weatherDataForResponseData:(NSData *)data request:(CZWeatherRequest *)request;

// -----
// @name Properties
// -----

#pragma mark Properties

/**
 API key for the given service.
 */
@property (nonatomic, readonly) NSString    *key;

/**
 Human-readable name for the weather service
 */
@property (nonatomic, readonly) NSString    *serviceName;

@end



