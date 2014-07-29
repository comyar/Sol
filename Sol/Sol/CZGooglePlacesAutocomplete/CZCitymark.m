//
//  CZCitymark.h
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

#import "CZCitymark.h"

@interface CZCitymark ()

@property (nonatomic) NSString *locality;
@property (nonatomic) NSString *administrativeArea;
@property (nonatomic) NSString *country;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end


#pragma mark - CZCitymark Implementation

@implementation CZCitymark

+ (CZCitymark *)citymarkWithLocality:(NSString *)locality
                  administrativeArea:(NSString *)administrativeArea
                             country:(NSString *)country
                          coordinate:(CLLocationCoordinate2D)coordinate
{
    CZCitymark *citymark = [[CZCitymark alloc]init];
    citymark.locality = locality;
    citymark.administrativeArea = administrativeArea;
    citymark.country = country;
    citymark.coordinate = coordinate;
    return citymark;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.locality = [aDecoder decodeObjectForKey:@"locality"];
        self.administrativeArea = [aDecoder decodeObjectForKey:@"administrativeArea"];
        self.country = [aDecoder decodeObjectForKey:@"country"];
        self.coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:@"latitude"],
                                                     [aDecoder decodeDoubleForKey:@"longitude"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.locality forKey:@"locality"];
    [aCoder encodeObject:self.administrativeArea forKey:@"administrativeArea"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
}

@end
