//
//  SOLWeatherView.h
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

#import <CZWeatherKit/CZWeatherKit.h>


#pragma mark - Forward Declarations

@class SOLWeatherData;

/**
 SOLWeatherView is used to display weather data for a single location to the user. Every instance
 of SOLWeatherView is managed by SOLMainViewController only.
 */
@interface SOLWeatherView : UIView

// -----
// @name Properties
// -----

//  Displays the time the weather data for this view was last updated
@property (nonatomic, readonly) UILabel                 *updatedLabel;

//  Displays the icon for current conditions
@property (nonatomic, readonly) UILabel                 *conditionIconLabel;

//  Displays the description of current conditions
@property (nonatomic, readonly) UILabel                 *conditionDescriptionLabel;

//  Displays the location whose weather data is being represented by this weather view
@property (nonatomic, readonly) UILabel                 *locationLabel;

//  Displayes the current temperature
@property (nonatomic, readonly) UILabel                 *currentTemperatureLabel;

//  Displays both the high and low temperatures for today
@property (nonatomic, readonly) UILabel                 *highLowTemperatureLabel;

//  Displays the day of the week for the first forecast snapshot
@property (nonatomic, readonly) UILabel                 *forecastDayOneLabel;

//  Displays the day of the week for the second forecast snapshot
@property (nonatomic, readonly) UILabel                 *forecastDayTwoLabel;

//  Displays the day of the week for the third forecast snapshot
@property (nonatomic, readonly) UILabel                 *forecastDayThreeLabel;

//  Displays the icon representing the predicted conditions for the first forecast snapshot
@property (nonatomic, readonly) UILabel                 *forecastIconOneLabel;

//  Displays the icon representing the predicted conditions for the second forecast snapshot
@property (nonatomic, readonly) UILabel                 *forecastIconTwoLabel;

//  Displays the icon representing the predicted conditions for the third forecast snapshot
@property (nonatomic, readonly) UILabel                 *forecastIconThreeLabel;

//  Indicates whether data is being downloaded for this weather view
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

// Background image view to display image of city fetched from Flickr (or defaults)
@property (nonatomic, readonly) UIImageView             *backgroundImageView;

@end
