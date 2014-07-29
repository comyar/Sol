//
//  CZGooglePlacesAutocomplete.m
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

#import "CZGooglePlacesAutocomplete.h"
#import "CZCitymark.h"


#pragma mark - Constants

NSString * const CZGooglePlacesOffsetOptionName         = @"CZGooglePlacesOffsetOptionName";
NSString * const CZGooglePlacesLocationOptionName       = @"CZGooglePlacesLocationOptionName";
NSString * const CZGooglePlacesRadiusOptionName         = @"CZGooglePlacesRadiusOptionName";
NSString * const CZGooglePlacesLanguageOptionName       = @"CZGooglePlacesLanguageOptionName";
NSString * const CZGooglePlacesTypeOptionName           = @"CZGooglePlacesTypeOptionName";
NSString * const CZGooglePlacesAutocompleteErrorDomain  = @"CZGooglePlacesAutocompleteErrorDomain";

// Google Places API key
static NSString * APIkey = nil;

// Endpoint of Google Places API
static NSString * const endpoint = @"https://maps.googleapis.com/maps/api/place";


#pragma mark - CZGooglePlacesAutocomplete Implementation

@implementation CZGooglePlacesAutocomplete

+ (void)provideAPIKey:(NSString *)key
{
    APIkey = key;
}

+ (void)autocompleteWithText:(NSString *)text options:(NSDictionary *)options completion:(CZGooglePlacesAutocompleteCompletion)completion
{
    if (!completion) {
        return;
    }
    
    NSURL *url = [CZGooglePlacesAutocomplete autocompleteURLForText:text options:options];
    
    if (!url) {
        [CZGooglePlacesAutocomplete failWithError:CZGooglePlacesAutocompleteInvalidConfigurationError completion:completion];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if (JSON) {
            
            if ([JSON[@"status"]isEqualToString:@"OK"]) {
                
                NSArray *predictions = JSON[@"predictions"];
                
                __block NSInteger requestsCompleted = 0;
                __block NSMutableArray *citymarks = [NSMutableArray new];
                
                for (NSDictionary *prediction in predictions) {
                    NSString *placeID = prediction[@"place_id"];
                    NSURL *url = [CZGooglePlacesAutocomplete detailsURLForPlaceID:placeID
                                                                         language:options[CZGooglePlacesLanguageOptionName]];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        if (JSON) {
                            CZCitymark *citymark = [CZGooglePlacesAutocomplete citymarkForPlaceDetail:JSON];
                            if (citymark) {
                                [citymarks addObject:citymark];
                            }
                            
                            if (++requestsCompleted >= [predictions count]) {
                                completion(citymarks, nil);
                            }
                        }
                    }];
                }
            } else {
                [CZGooglePlacesAutocomplete failWithError:CZGooglePlacesAutocompleteServerStatusError completion:completion];
            }
        } else {
            [CZGooglePlacesAutocomplete failWithError:CZGooglePlacesAutocompleteResultParsingError completion:completion];
        }
    }];
}

+ (CZCitymark *)citymarkForPlaceDetail:(NSDictionary *)placeDetail
{
    NSString *locality              = nil;
    NSString *administrativeArea    = nil;
    NSString *country               = nil;
    CLLocationCoordinate2D coordinate;
    
    if ([placeDetail[@"status"]isEqualToString:@"OK"]) {
        NSArray *addressComponents = placeDetail[@"result"][@"address_components"];
        for (NSDictionary *component in addressComponents) {
            NSArray *types = component[@"types"];
            for (NSString *type in types) {
                
                if ([type isEqualToString:@"locality"]) {
                    locality = component[@"long_name"];
                }
                
                if ([type isEqualToString:@"administrative_area_level_1"]) {
                    administrativeArea = component[@"short_name"];
                }
                
                if ([type isEqualToString:@"country"]) {
                    country = component[@"long_name"];
                }
            }
        }
        
        if ([locality length] && [administrativeArea length] && [country length]) {
            CLLocationDegrees latitude = [placeDetail[@"result"][@"geometry"][@"location"][@"lat"]doubleValue];
            CLLocationDegrees longitude = [placeDetail[@"result"][@"geometry"][@"location"][@"lng"]doubleValue];
            coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            return [CZCitymark citymarkWithLocality:locality
                                 administrativeArea:administrativeArea
                                            country:country
                                         coordinate:coordinate];
        }
    }
    
    return nil;
}

+ (NSURL *)detailsURLForPlaceID:(NSString *)placeID language:(NSString *)language
{
    if ([placeID length] && [APIkey length]) {
        NSString *urlString = [NSString stringWithFormat:@"%@/details/json?placeid=%@&key=%@", endpoint, placeID, APIkey];
        
        if ([language length]) {
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&language=%@", language]];
        }
        
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

+ (NSURL *)autocompleteURLForText:(NSString *)text options:(NSDictionary *)options
{
    if ([text length] && [APIkey length]) {
        text = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/autocomplete/json?input=%@&key=%@", endpoint, text, APIkey];
        
        if ([options[CZGooglePlacesOffsetOptionName] isKindOfClass:[NSNumber class]]) {
            NSUInteger offset = [options[CZGooglePlacesOffsetOptionName] integerValue];
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&offset=%lud", (unsigned long)offset]];
        }
        
        if ([options[CZGooglePlacesLocationOptionName] isKindOfClass:[CLLocation class]]) {
            CLLocation *location = options[CZGooglePlacesLocationOptionName];
            CLLocationDegrees latitude = location.coordinate.latitude;
            CLLocationDegrees longitude = location.coordinate.longitude;
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&location=%f,%f", latitude, longitude]];
        }
        
        if ([options[CZGooglePlacesRadiusOptionName] isKindOfClass:[NSNumber class]]) {
            NSUInteger radius = [options[CZGooglePlacesRadiusOptionName] integerValue];
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&radius=%lud", (unsigned long)radius]];
        }
        
        if ([options[CZGooglePlacesLanguageOptionName] isKindOfClass:[NSString class]]) {
            NSString *language = options[CZGooglePlacesLanguageOptionName];
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&language=%@", language]];
        }
        
        if ([options[CZGooglePlacesTypeOptionName] isKindOfClass:[NSString class]]) {
            NSString *type = options[CZGooglePlacesTypeOptionName];
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&types=%@", type]];
        }
        
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

+ (void)failWithError:(CZGooglePlacesAutocompleteError)error completion:(CZGooglePlacesAutocompleteCompletion)completion
{
    completion(nil, [NSError errorWithDomain:@"CZGooglePlacesAutocompleteErrorDomain"
                                        code:error
                                    userInfo:nil]);
}

@end
