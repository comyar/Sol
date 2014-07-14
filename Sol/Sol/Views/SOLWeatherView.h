//
//  SOLWeatherView.h
//  Copyright (c) 2013 Comyar Zaheri
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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
@property (nonatomic, readonly) UILabel *updatedLabel;

//  Displays the icon for current conditions
@property (nonatomic, readonly) UILabel *conditionIconLabel;

//  Displays the description of current conditions
@property (nonatomic, readonly) UILabel *conditionDescriptionLabel;

//  Displays the location whose weather data is being represented by this weather view
@property (nonatomic, readonly) UILabel *locationLabel;

//  Displayes the current temperature
@property (nonatomic, readonly) UILabel *currentTemperatureLabel;

//  Displays both the high and low temperatures for today
@property (nonatomic, readonly) UILabel *hiloTemperatureLabel;

//  Displays the day of the week for the first forecast snapshot
@property (nonatomic, readonly) UILabel *forecastDayOneLabel;

//  Displays the day of the week for the second forecast snapshot
@property (nonatomic, readonly) UILabel *forecastDayTwoLabel;

//  Displays the day of the week for the third forecast snapshot
@property (nonatomic, readonly) UILabel *forecastDayThreeLabel;

//  Displays the icon representing the predicted conditions for the first forecast snapshot
@property (nonatomic, readonly) UILabel *forecastIconOneLabel;

//  Displays the icon representing the predicted conditions for the second forecast snapshot
@property (nonatomic, readonly) UILabel *forecastIconTwoLabel;

//  Displays the icon representing the predicted conditions for the third forecast snapshot
@property (nonatomic, readonly) UILabel *forecastIconThreeLabel;

//  Indicates whether data is being downloaded for this weather view
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@end
