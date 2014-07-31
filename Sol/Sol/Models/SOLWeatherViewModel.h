//
//  SOLWeatherViewModel.h
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

#import <Foundation/Foundation.h>
#import <CZWeatherKit/CZWeatherKit.h>


#pragma mark - SOLWeatherViewModel Interface

/**
 */
@interface SOLWeatherViewModel : NSObject

// -----
// @name Creating a SOLWeatherViewModel
// -----

/**
 */
+ (SOLWeatherViewModel *)weatherViewModelForPlacemark:(CLPlacemark *)placemark
                              currentWeatherCondition:(CZWeatherCondition *)currentWeatherCondition
                            forecastWeatherConditions:(NSArray *)forecastWeatherConditions
                                              celsius:(BOOL)celsius;

// -----
// @name Properties
// -----

//
@property (nonatomic, readonly) NSString *conditionIconString;

//
@property (nonatomic, readonly) NSString *conditionLabelString;

//
@property (nonatomic, readonly) NSString *locationLabelString;

//
@property (nonatomic, readonly) NSString *currentTemperatureLabelString;

//
@property (nonatomic, readonly) NSString *highLowTemperatureLabelString;

//
@property (nonatomic, readonly) NSString *forecastDayOneLabelString;

//
@property (nonatomic, readonly) NSString *forecastIconOneLabelString;

//
@property (nonatomic, readonly) NSString *forecastDayTwoLabelString;

//
@property (nonatomic, readonly) NSString *forecastIconTwoLabelString;

//
@property (nonatomic, readonly) NSString *forecastDayThreeLabelString;

//
@property (nonatomic, readonly) NSString *forecastIconThreeLabelString;

@end
