//
//  CZWeatherLocation.m
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

#import "CZWeatherLocation.h"


#pragma mark - Macros

#if !(TARGET_OS_IPHONE)
#define valueWithCGPoint valueWithPoint
#endif


#pragma mark - Constants

// Key for the location's city in the locationData dictionary
NSString * const CZWeatherLocationCityName          = @"CZWeatherLocationCityName";

// Key for the location's state in the locationData dictionary
NSString * const CZWeatherLocationStateName         = @"CZWeatherLocationStateName";

// Key for the location's country in the locationData dictionary
NSString * const CZWeatherLocationCountryName       = @"CZWeatherLocationCountryName";

// Key for the location's zipcode in the locationData dictionary
NSString * const CZWeatherLocationZipcodeName       = @"CZWeatherLocationZipcodeName";

// Key for the location's coordinate in the locationData dictionary
NSString * const CZWeatherLocationCoordinateName    = @"CZWeatherLocationCoordinateName";


#pragma mark - CZWeatherLocation Class Extension

@interface CZWeatherLocation ()

// Contains the location information provided when the object was created.
@property (nonatomic) NSDictionary          *locationData;

// Indicates the type of location object.
@property (nonatomic) CZWeatherLocationType locationType;

@end


#pragma mark - CZWeatherLocation Implementation

@implementation CZWeatherLocation

#pragma mark Creating a Weather Location

- (instancetype)initWithLocationType:(CZWeatherLocationType)locationType
{
    if (self = [super init]) {
        self.locationType = locationType;
    }
    return self;
}

+ (CZWeatherLocation *)locationWithAutoIP
{
    CZWeatherLocation *weatherLocation = [CZWeatherLocation new];
    return weatherLocation;
}

+ (CZWeatherLocation *)locationWithZipcode:(NSString *)zipcode
{
    CZWeatherLocation *weatherLocation = [[CZWeatherLocation alloc]initWithLocationType:CZWeatherLocationZipcodeType];
    if (zipcode) {
        weatherLocation.locationData = @{CZWeatherLocationZipcodeName: zipcode};
    }
    return weatherLocation;
}

+ (CZWeatherLocation *)locationWithCLLocation:(CLLocation *)location
{
    CZWeatherLocation *weatherLocation = [[CZWeatherLocation alloc]initWithLocationType:CZWeatherLocationCoordinateType];
    CLLocationCoordinate2D coordinate = location.coordinate;
    CGPoint coordinatePoint = CGPointMake(coordinate.latitude, coordinate.longitude);
    weatherLocation.locationData = @{CZWeatherLocationCoordinateName: [NSValue valueWithCGPoint:coordinatePoint]};
    return weatherLocation;
}

+ (CZWeatherLocation *)locationWithCLPlacemark:(CLPlacemark *)placemark
{
    CZWeatherLocation *weatherLocation = [[CZWeatherLocation alloc]initWithLocationType:CZWeatherLocationCoordinateType];
    CLLocationCoordinate2D coordinate = placemark.location.coordinate;
    CGPoint coordinatePoint = CGPointMake(coordinate.latitude, coordinate.longitude);
    weatherLocation.locationData = @{CZWeatherLocationCoordinateName: [NSValue valueWithCGPoint:coordinatePoint]};
    return weatherLocation;
}

+ (CZWeatherLocation *)locationWithCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate
{
    CZWeatherLocation *weatherLocation = [[CZWeatherLocation alloc]initWithLocationType:CZWeatherLocationCoordinateType];
    CGPoint coordinatePoint = CGPointMake(coordinate.latitude, coordinate.longitude);
    weatherLocation.locationData = @{CZWeatherLocationCoordinateName: [NSValue valueWithCGPoint:coordinatePoint]};
    return weatherLocation;
}

+ (CZWeatherLocation *)locationWithCity:(NSString *)city state:(NSString *)state
{
    CZWeatherLocation *weatherLocation = [[CZWeatherLocation alloc]initWithLocationType:CZWeatherLocationCityStateType];
    if (city && state) {
        weatherLocation.locationData = @{CZWeatherLocationCityName: city,
                                         CZWeatherLocationStateName: state};
    }
    return weatherLocation;
}

+ (CZWeatherLocation *)locationWithCity:(NSString *)city country:(NSString *)country
{
    CZWeatherLocation *weatherLocation = [[CZWeatherLocation alloc]initWithLocationType:CZWeatherLocationCityCountryType];
    if (city && country) {
        weatherLocation.locationData = @{CZWeatherLocationCityName: city,
                                         CZWeatherLocationCountryName: country};
    }
    return weatherLocation;
}

@end
