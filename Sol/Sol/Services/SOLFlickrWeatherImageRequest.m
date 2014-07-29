//
//  SOLFlickrRequest.m
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

#import "SOLFlickrWeatherImageRequest.h"


#pragma mark - Constants

static NSString * const endpoint = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&accuracy=11&safe_search=1&content_type=1&group_id=1463451@N25&format=json";


#pragma mark - SOLFlickrRequest Implementation

@implementation SOLFlickrWeatherImageRequest

+ (void)sendRequestForAPIKey:(NSString *)APIKey
                    coordinate:(CLLocationCoordinate2D)coordinate
                    keywords:(NSArray *)keywords
                  completion:(SOLFlickrRequestCompletion)completion
{
    
    NSString *urlString = [endpoint copy];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&api_key=%@&lat=%f&lon=%f&",
                                                    APIKey, coordinate.latitude, coordinate.longitude]];
    if ([keywords count]) {
        urlString = [urlString stringByAppendingString:[keywords componentsJoinedByString:@"+"]];
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%@", data);
        if (data) {
            NSError *error;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"%@", error);
            if ([JSON[@"stat"]isEqualToString:@"ok"]) {
                NSArray *photos = JSON[@"photos"][@"photo"];
                if ([photos count] > 0) {
                    NSDictionary *photo = photos[arc4random() % [photos count]];
                    NSURL *imageURL = [SOLFlickrWeatherImageRequest imageURLFromPhotoDictionary:photo];
                    completion(imageURL, nil);
                }
            }
        }
    }];
    
}

+ (NSURL *)imageURLFromPhotoDictionary:(NSDictionary *)photoDictionary
{
    NSString *urlString = [NSString stringWithFormat:@"https://farm{%@}.staticflickr.com/%@/%@_%@_b.jpg",
                           photoDictionary[@"farm"],
                           photoDictionary[@"server"],
                           photoDictionary[@"id"],
                           photoDictionary[@"secret"]];
    return [NSURL URLWithString:urlString];
}

@end
