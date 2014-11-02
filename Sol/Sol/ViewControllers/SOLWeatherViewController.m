//
//  SOLWeatherViewController.m
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

#import "SOLWeatherViewController.h"
#import "SOLWeatherRequestHandler.h"
#import "SOLNotificationGlobals.h"
#import "SOLWeatherViewModel.h"
#import "SOLSettingsManager.h"
#import "SOLWeatherView.h"
#import "SOLErrorView.h"


#pragma mark - Constants

static NSString * const CelsiusKeyPathName  = @"celsius";
static NSString * const DefaultGradientName = @"gradient5";

// Minimum number of seconds between updates
static const NSTimeInterval minimumTimeBetweenUpdates = 3600.0;


#pragma mark - SOLWeatherViewController Class Extension

@interface SOLWeatherViewController ()

// YES if the weather view controller is currently fetching data for an update
@property (nonatomic, getter=isUpdating) BOOL   updating;

// YES if the placemark has changed and a successful update has not occurred.
@property (nonatomic) BOOL                      dirtyPlacemark;

@property (nonatomic) SOLWeatherView            *weatherView;
@property (nonatomic) SOLErrorView              *errorView;

@end


#pragma mark - SOLWeatherViewController Implementation

@implementation SOLWeatherViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithPlacemark:nil];
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.placemark = placemark;
        
        [[SOLSettingsManager sharedManager]addObserver:self
                                            forKeyPath:CelsiusKeyPathName
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(observeNotification:)
                                                    name:SOLAppDidBecomeActiveNotification
                                                  object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
    self.weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:DefaultGradientName]];
    [self.view addSubview:self.weatherView];
    
    [self update];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [SOLSettingsManager sharedManager]) {
        if ([keyPath isEqualToString:CelsiusKeyPathName]) {
            [self update];
        }
    }
}

- (void)observeNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:SOLAppDidBecomeActiveNotification]) {
        [self update];
    }
}

- (void)update
{
    [self.weatherView.activityIndicator startAnimating];
    [SOLWeatherRequestHandler weatherViewModelForRequest:self.placemark completion: ^ (SOLWeatherViewModel *weatherViewModel) {
        [self.weatherView.activityIndicator stopAnimating];
        
        // Set temperature mode
        weatherViewModel.temperatureMode = [SOLSettingsManager sharedManager].celsius? SOLCelsiusMode : SOLFahrenheitMode;
        
        // Set label text
        self.weatherView.locationLabel.text             = weatherViewModel.locationLabelString;
        self.weatherView.conditionIconLabel.text        = weatherViewModel.conditionIconString;
        self.weatherView.highLowTemperatureLabel.text   = weatherViewModel.highLowTemperatureLabelString;
        self.weatherView.conditionDescriptionLabel.text = weatherViewModel.conditionDescriptionLabelString;
        self.weatherView.currentTemperatureLabel.text   = weatherViewModel.currentTemperatureLabelString;
        self.weatherView.forecastDayOneLabel.text       = weatherViewModel.forecastDayOneLabelString;
        self.weatherView.forecastIconOneLabel.text      = weatherViewModel.forecastDayTwoLabelString;
        self.weatherView.forecastDayTwoLabel.text       = weatherViewModel.forecastDayTwoLabelString;
        self.weatherView.forecastIconTwoLabel.text      = weatherViewModel.forecastIconTwoLabelString;
        self.weatherView.forecastDayThreeLabel.text     = weatherViewModel.forecastDayThreeLabelString;
        self.weatherView.forecastIconThreeLabel.text    = weatherViewModel.forecastIconThreeLabelString;
        
        [UIView animateWithDuration:0.3 animations: ^ {
            self.weatherView.alpha = (weatherViewModel) ? 1.0 : 0.0;
            self.errorView.alpha = (weatherViewModel) ? 0.0 : 1.0;
        }];
    }];
}

- (void)dealloc
{
    [[SOLSettingsManager sharedManager]removeObserver:self
                                           forKeyPath:CelsiusKeyPathName];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
