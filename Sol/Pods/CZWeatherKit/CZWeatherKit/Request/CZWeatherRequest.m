//
//  CZWeatherRequest.m
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

#import "CZWeatherRequest.h"


#pragma mark - Constants

// Error domain for errors passed as arguments to CZWeatherRequestCompletion blocks.
NSString * const CZWeatherRequestErrorDomain = @"CZWeatherRequestErrorDomain";


#pragma mark - CZWeatherRequest Implementation

@implementation CZWeatherRequest

#pragma mark Creating a Weather Request

- (instancetype)init
{
    return [self initWithType:CZCurrentConditionsRequestType];
}

- (instancetype)initWithType:(CZWeatherRequestType)requestType
{
    if (self = [super init]) {
        _detailLevel            = CZWeatherRequestLightDetail;
        _requestType            = requestType;
    }
    return self;
}

+ (CZWeatherRequest *)requestWithType:(CZWeatherRequestType)requestType
{
    return [[CZWeatherRequest alloc]initWithType:requestType];
}

#pragma mark Using a Weather Request

- (void)performRequestWithHandler:(CZWeatherRequestHandler)handler
{
    if (!handler) {
        return;
    }
    
    if (!self.service) { // Requests require a service
        handler(nil, [NSError errorWithDomain:CZWeatherRequestErrorDomain
                                         code:CZWeatherRequestConfigurationError
                                     userInfo:nil]);
        return;
    }

     __weak CZWeatherRequest *weakRequest = self;
    NSURL *url = [self.service urlForRequest:weakRequest];
    
    if (!url) { // Error if no url provided by service
        handler(nil, [NSError errorWithDomain:CZWeatherRequestErrorDomain
                                         code:CZWeatherRequestServiceURLError
                                     userInfo:nil]);
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            id weatherData = [self.service weatherDataForResponseData:data request:weakRequest];
            if (weatherData) {
                handler(weatherData, nil);
            } else {    // Error if parsing failed
                handler(nil, [NSError errorWithDomain:CZWeatherRequestErrorDomain
                                                 code:CZWeatherRequestServiceParseError
                                             userInfo:nil]);
            }
        } else {
            handler(nil, connectionError);
        }
    }];
}

@end
