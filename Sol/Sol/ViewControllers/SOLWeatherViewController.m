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
#import "SOLWeatherView.h"
#import "SOLKeyReader.h"
#import "SOLWeatherViewModel.h"
#import "SOLSettingsManager.h"
#import "SOLNotificationGlobals.h"
#import "SOLWeatherData.h"
#import "SOLWeatherDataDownloader.h"
#import "DateTools.h"
#import "SOLWeatherDataManager.h"


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

// Redefinition of weather view property
@property (nonatomic) SOLWeatherView            *weatherView;

@property (nonatomic) SOLWeatherData            *weatherData;

@end


#pragma mark - SOLWeatherViewController Implementation

@implementation SOLWeatherViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithPlacemark:nil weatherData:nil];
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
                      weatherData:(SOLWeatherData *)weatherData
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.placemark = placemark;
        self.weatherData = weatherData;
        
        [[SOLSettingsManager sharedManager]addObserver:self
                                            forKeyPath:CelsiusKeyPathName
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(observeNotification:)
                                                    name:SOLAppDidBecomeActiveNotification
                                                  object:nil];
        [self updateWeatherView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
    self.weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:DefaultGradientName]];
    [self.view addSubview:self.weatherView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [SOLSettingsManager sharedManager]) {
        if ([keyPath isEqualToString:CelsiusKeyPathName]) {
            [self updateWeatherView];
        }
    }
}

- (void)observeNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:SOLAppDidBecomeActiveNotification]) {
        if (!self.isLocal) {
            [self update];
        }
    }
}

- (void)update
{
    if (self.weatherData) {
        self.weatherView.updatedLabel.text = [[NSString stringWithFormat:@"Updated %@", [self.weatherData.timestamp timeAgoSinceNow]]capitalizedString];
    }
    
    // If the time since the last update hasn't exceed an hour, don't update
    if (!self.dirtyPlacemark && self.weatherData) {
        if ([self.weatherData.currentCondition.date timeIntervalSinceNow] > -minimumTimeBetweenUpdates) {
            return;
        }
    }
    
    // Ensure we have a location
    if (!self.placemark || self.isUpdating) {
        return;
    }
    
    self.updating = YES;
    [self.weatherView.activityIndicator startAnimating];
    
    [SOLWeatherDataDownloader weatherDataForPlacemark:self.placemark withCompletion: ^ (SOLWeatherData *weatherData) {
        if (weatherData) {
            self.weatherData = weatherData;
        }
        [self.weatherView.activityIndicator stopAnimating];
        [self updateWeatherView];
        self.updating = NO;
    }];
    
}

- (void)updateWeatherView
{
    if (self.placemark && self.weatherData) {
        SOLWeatherViewModel *weatherViewModel = [SOLWeatherViewModel weatherViewModelForPlacemark:self.placemark
                                                                                      weatherData:self.weatherData
                                                                                         celsius:[SOLSettingsManager sharedManager].isCelsius];
        self.weatherView.locationLabel.text             = weatherViewModel.locationLabelString;
        self.weatherView.conditionIconLabel.text        = weatherViewModel.conditionIconString;
        self.weatherView.conditionDescriptionLabel.text = weatherViewModel.conditionLabelString;
        self.weatherView.highLowTemperatureLabel.text   = weatherViewModel.highLowTemperatureLabelString;
        self.weatherView.currentTemperatureLabel.text   = weatherViewModel.currentTemperatureLabelString;
        self.weatherView.forecastDayOneLabel.text       = weatherViewModel.forecastDayOneLabelString;
        self.weatherView.forecastDayTwoLabel.text       = weatherViewModel.forecastDayTwoLabelString;
        self.weatherView.forecastDayThreeLabel.text     = weatherViewModel.forecastDayThreeLabelString;
        self.weatherView.forecastIconOneLabel.text      = weatherViewModel.forecastIconOneLabelString;
        self.weatherView.forecastIconTwoLabel.text      = weatherViewModel.forecastIconTwoLabelString;
        self.weatherView.forecastIconThreeLabel.text    = weatherViewModel.forecastIconThreeLabelString;
        
        self.weatherView.activityIndicator.center = CGPointMake(self.weatherView.activityIndicator.center.x,
                                                                0.85 * CGRectGetHeight(self.weatherView.bounds));
        self.weatherView.updatedLabel.text = [[NSString stringWithFormat:@"Updated %@", [self.weatherData.timestamp timeAgoSinceNow]]capitalizedString];
    } else {
        // show failure
    }
}

- (void)updateDidFail
{
    
    self.updating = NO;
}

- (void)dealloc
{
    [[SOLSettingsManager sharedManager]removeObserver:self
                                           forKeyPath:CelsiusKeyPathName];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark Setters

- (void)setPlacemark:(CLPlacemark *)placemark
{
    _placemark = placemark;
    self.dirtyPlacemark = YES;
}

@end
