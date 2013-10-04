//
//  SOLMainViewController.m
//  Sol
//
//  Created by Comyar Zaheri on 7/30/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLMainViewController.h"
#import "SOLPagingScrollView.h"
#import "SOLStateManager.h"
#import "SOLWeatherData.h"
#import "UIImage+ImageEffects.h"
#import "UIView+Screenshot.h"

/** Constants */
#define kMIN_TIME_SINCE_UPDATE          3600
#define kMAX_NUM_WEATHER_VIEWS          5
#define kLOCAL_WEATHER_VIEW_TAG         0
#define kDEFAULT_BACKGROUND_GRADIENT    @"gradient5"


#pragma mark - SOLMainViewController Class Extension

@interface SOLMainViewController ()
{
    /// Dark, semi-transparent view to sit above the homescreen
    UIView                  *_darkenedBackgroundView;
    
    /// Label displaying the Sol° logo
    UILabel                 *_solLogoLabel;
    
    /// Label displaying the name of the app
    UILabel                 *_solTitleLabel;
    
    /// Contains blurred screenshots of this controller's view when transitioning to another controller
    UIImageView             *_blurredOverlayView;
    
    /// Dictionary of all weather data being managed by the app
    NSMutableDictionary     *_weatherData;
    
    /// Ordered-List of weather tags
    NSMutableArray          *_weatherTags;
    
    /// Formats weather data timestamps
    NSDateFormatter         *_dateFormatter;
    
    BOOL                    _isScrolling;
}
@end

#pragma mark - SOLMainViewController Implementation

@implementation SOLMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        /// Initialize the weather data dictionary with saved data, if it exists
        if([SOLStateManager weatherData]) {
            self->_weatherData = [NSMutableDictionary dictionaryWithDictionary:[SOLStateManager weatherData]];
        } else {
            self->_weatherData = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        
        /// Initialize the weather tags array with saved data, if it exists
        if([SOLStateManager weatherTags]) {
            self->_weatherTags = [NSMutableArray arrayWithArray:[SOLStateManager weatherTags]];
        } else {
            self->_weatherTags = [NSMutableArray arrayWithCapacity:4];
        }
        
        self->_dateFormatter = [[NSDateFormatter alloc]init];
        [self->_dateFormatter setDateFormat:@"EEE MMM d, h:mm a"];
        
        [self initializeViewControllers];
        [self initializeSubviews];
        [self initializeSettingsButton];
        [self initializeAddLocationButton];
        
        if([self->_weatherData count] >= kMAX_NUM_WEATHER_VIEWS) {
            self.addLocationButton.hidden = YES;
        }
        
        /// The blurred overlay view should sit in front of all other subviews
        [self.view bringSubviewToFront:_blurredOverlayView];
    }
    return self;
}

- (void)initializeViewControllers
{
    /// Initialize the add location view controller
    self->_addLocationViewController = [[SOLAddLocationViewController alloc]initWithNibName:nil bundle:nil];
    self->_addLocationViewController.delegate = self;
    
    /// Initialize the settings view controller
    self->_settingsViewController = [[SOLSettingsViewController alloc]initWithNibName:nil bundle:nil];
    self->_settingsViewController.delegate = self;
}

- (void)initializeSubviews
{
    /// Initialize the darkended background view
    self->_darkenedBackgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self->_darkenedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:_darkenedBackgroundView];
    
    /// Initialize the Sol° logo label
    self->_solLogoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 160)];
    self->_solLogoLabel.center = CGPointMake(self.view.center.x, 0.5 * self.view.center.y);
    self->_solLogoLabel.font = [UIFont fontWithName:CLIMACONS_FONT size:200];
    self->_solLogoLabel.backgroundColor = [UIColor clearColor];
    self->_solLogoLabel.textColor = [UIColor whiteColor];
    self->_solLogoLabel.textAlignment = NSTextAlignmentCenter;
    self->_solLogoLabel.text = [NSString stringWithFormat:@"%c", ClimaconSun];
    [self.view addSubview:_solLogoLabel];

    /// Initialize the Sol° title label
    self->_solTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    self->_solTitleLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
    self->_solTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:64];
    self->_solTitleLabel.backgroundColor = [UIColor clearColor];
    self->_solTitleLabel.textColor = [UIColor whiteColor];
    self->_solTitleLabel.textAlignment = NSTextAlignmentCenter;
    self->_solTitleLabel.text = @"Sol°";
    [self.view addSubview:_solTitleLabel];

    /// Initialize the paging scroll wiew
    self->_pagingScrollView = [[SOLPagingScrollView alloc]initWithFrame:self.view.bounds];
    self->_pagingScrollView.delegate = self;
    [self.view addSubview:self->_pagingScrollView];
    
    /// Initialize the page control
    self->_pageControl = [[UIPageControl alloc]initWithFrame: CGRectMake(0, self.view.bounds.size.height - 32,
                                                                         self.view.bounds.size.width, 32)];
    [self->_pageControl setHidesForSinglePage:YES];
    [self.view addSubview:self->_pageControl];
    
    /// Initialize the blurred overlay view
    _blurredOverlayView = [[UIImageView alloc]initWithImage:[[UIImage alloc]init]];
    [_blurredOverlayView setFrame:self.view.bounds];
    [self.view addSubview:_blurredOverlayView];
}

- (void)initializeAddLocationButton
{
    self->_addLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *plusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [plusLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:40]];
    [plusLabel setTextAlignment:NSTextAlignmentCenter];
    [plusLabel setTextColor:[UIColor whiteColor]];
    [plusLabel setText:@"+"];
    [self.addLocationButton addSubview:plusLabel];
    [self.addLocationButton setFrame:CGRectMake(self.view.bounds.size.width - 44, self.view.bounds.size.height - 54, 44, 44)];
    [self.addLocationButton setShowsTouchWhenHighlighted:YES];
    [self.addLocationButton addTarget:self action:@selector(addLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self->_addLocationButton];
}

- (void)initializeSettingsButton
{
    self->_settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [self->_settingsButton setTintColor:[UIColor whiteColor]];
    [self->_settingsButton setFrame:CGRectMake(4, self.view.bounds.size.height - 48, 44, 44)];
    [self->_settingsButton setShowsTouchWhenHighlighted:YES];
    [self->_settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self->_settingsButton];
}

- (void)initializeLocalWeatherView
{
    SOLWeatherView *localWeatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
    localWeatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kDEFAULT_BACKGROUND_GRADIENT]];
    localWeatherView.local = YES;
    localWeatherView.delegate = self;
    localWeatherView.tag = kLOCAL_WEATHER_VIEW_TAG;
    [_pagingScrollView addSubview:localWeatherView];
    self->_pageControl.numberOfPages += 1;
    
    SOLWeatherData *localWeatherData = [self->_weatherData objectForKey:[NSNumber numberWithInteger:kLOCAL_WEATHER_VIEW_TAG]];
    if(localWeatherData) {
        [self updateWeatherView:localWeatherView withData:localWeatherData];
    }
}

- (void)initializeNonlocalWeatherViews
{
    for(NSNumber *tagNumber in self->_weatherTags) {
        /// Initialize a new weather view for all weather data not belonging to the local weather view
        SOLWeatherData *weatherData = [self->_weatherData objectForKey:tagNumber];
        if(weatherData) {
            SOLWeatherView *weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
            weatherView.delegate = self;
            weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient5.png"]];
            weatherView.tag = tagNumber.integerValue;
            weatherView.local = NO;
            [_pagingScrollView addSubview:weatherView];
            self->_pageControl.numberOfPages += 1;
            [self updateWeatherView:weatherView withData:weatherData];
        }
    }
}

#pragma mark Using a SOLMainViewController

- (void)showBlurredOverlayView:(BOOL)show
{
    if(show) {
        /// Take a screen shot of this controller's view
        UIImage *screenshot = [self.view screenshot];
        
        /// Blur the screen shot
        UIImage *blurredScreenshot = [screenshot applyBlurWithRadius:10.0
                                                           tintColor:[UIColor colorWithWhite:0.0 alpha:0.25]
                                               saturationDeltaFactor:1.0
                                                           maskImage:nil];
        /// Set the blurred overlay view's image with the blurred screenshot
        [_blurredOverlayView setImage:blurredScreenshot];
        CZLog(@"SOLMainViewController", @"Showing Blurred Overlay View");
    }
    
    /// Fade the blurred overlay view in or out based on the given input
    [UIView animateWithDuration:0.3 animations: ^ {
        _blurredOverlayView.alpha = (show)? 1.0: 0.0;
    }];
}

#pragma mark Updating Weather Data

- (void)updateWeatherData
{
    CZLog(@"SOLMainViewController", @"Attempting to update weather data");
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.local == NO) {
            
            /// Only update non local weather data
            SOLWeatherData *weatherData = [self->_weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            
            /// Only update if the minimum time for updates has passed
            if([[NSDate date]timeIntervalSinceDate:weatherData.timestamp] >= kMIN_TIME_SINCE_UPDATE || !weatherView.hasData) {
                CZLog(@"SOLMainViewController", @"Updating Weather Data for %@, Time Since: %f", weatherData.placemark.locality, [[NSDate date]timeIntervalSinceDate:weatherData.timestamp]);
                
                /// If the weather view is already showing data, we need to move the activity indicator
                if(weatherView.hasData) {
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                }
                [weatherView.activityIndicator startAnimating];
                
                /// Make the data download request
                [[SOLWundergroundDownloader sharedDownloader]dataForPlacemark:weatherData.placemark withTag:weatherView.tag delegate:self];
            } else {
                CZLog(@"SOLMainViewController", @"Not Updating Weather Data for %@, Time Since: %f", weatherData.placemark.locality, [[NSDate date]timeIntervalSinceDate:weatherData.timestamp]);
            }
        }
    }
}

- (void)updateWeatherView:(SOLWeatherView *)weatherView withData:(SOLWeatherData *)data
{
    if(!data) {
        return;
    }
    
    CZLog(@"SOLMainViewController", @"Updating labels for weather view with tag: %d", weatherView.tag);
    
    weatherView.hasData = YES;
    
    /// Set the update time
    weatherView.updatedLabel.text = [NSString stringWithFormat:@"Updated %@", [self->_dateFormatter stringFromDate:data.timestamp]];
    
    /// Set the current condition icon and description
    weatherView.conditionIconLabel.text         = data.currentSnapshot.icon;
    weatherView.conditionDescriptionLabel.text  = data.currentSnapshot.conditionDescription;
    
    /// Only show the country name if not the United States
    NSString *city      = data.placemark.locality;
    NSString *state     = data.placemark.administrativeArea;
    NSString *country   = data.placemark.country;
    if([[country lowercaseString] isEqualToString:@"united states"]) {
        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
    } else {
        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, country];
    }
    
    SOLTemperature currentTemperature   = data.currentSnapshot.currentTemperature;
    SOLTemperature highTemperature      = data.currentSnapshot.highTemperature;
    SOLTemperature lowTemperature       = data.currentSnapshot.lowTemperature;
    
    /// Set the temperature labels depending on the current scale set in the settings
    if([SOLStateManager temperatureScale] == SOLFahrenheitScale) {
        weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", currentTemperature.fahrenheit];
        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", highTemperature.fahrenheit, lowTemperature.fahrenheit];
    } else {
        weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", currentTemperature.celsius];
        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", highTemperature.celsius, lowTemperature.celsius];
    }
    
    SOLWeatherSnapshot *forecastDayOneSnapshot      = [data.forecastSnapshots objectAtIndex:0];
    SOLWeatherSnapshot *forecastDayTwoSnapshot      = [data.forecastSnapshots objectAtIndex:1];
    SOLWeatherSnapshot *forecastDayThreeSnapshot    = [data.forecastSnapshots objectAtIndex:2];
    
    /// Set the weather view's forcast day labels
    weatherView.forecastDayOneLabel.text    = [forecastDayOneSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
    weatherView.forecastDayTwoLabel.text    = [forecastDayTwoSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
    weatherView.forecastDayThreeLabel.text  = [forecastDayThreeSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
    
    /// Set the weather view's forecast icons
    weatherView.forecastIconOneLabel.text   = forecastDayOneSnapshot.icon;
    weatherView.forecastIconTwoLabel.text   = forecastDayTwoSnapshot.icon;
    weatherView.forecastIconThreeLabel.text = forecastDayThreeSnapshot.icon;
    
    /// Set the weather view's background color
    CGFloat fahrenheit = MIN(MAX(0, currentTemperature.fahrenheit), 99);
    NSString *gradientImageName = [NSString stringWithFormat:@"gradient%d.png", (int)floor(fahrenheit / 10.0)];
    weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:gradientImageName]];
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    /// Only add the local weather view if location services authorized
    if(status == kCLAuthorizationStatusAuthorized) {
        CZLog(@"SOLMainViewController", @"Location Services Authorized");
        [self initializeLocalWeatherView];
        [self initializeNonlocalWeatherViews];
        [self updateWeatherData];
    } else if(status != kCLAuthorizationStatusNotDetermined) {
        CZLog(@"SOLMainViewController", @"Location Services Authorization Not Determined");
        [self initializeNonlocalWeatherViews];
    } else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        CZLog(@"SOLMainViewController", @"Location Services Denied");
        /// If location services are disabled and no saved weather data is found, show the add location view controller
        if([self->_pagingScrollView.subviews count] == 0) {
            [self presentViewController:_addLocationViewController animated:YES completion:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CZLog(@"SOLMainViewController", @"Location Manager Updated Location");
    /// Download new weather data for the local weather view
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.local == YES) {
            SOLWeatherData *weatherData = [self->_weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            
            /// Only update weather data if the time since last update has exceeded the minimum time
            if([[NSDate date]timeIntervalSinceDate:weatherData.timestamp] >= kMIN_TIME_SINCE_UPDATE || !weatherView.hasData) {
                CZLog(@"SOLMainViewController", @"Updating Local Weather Data, Time Since: %f", [[NSDate date]timeIntervalSinceDate:weatherData.timestamp]);
                /// If the weather view has data, move the activity indicator to not overall with any labels
                if(weatherView.hasData) {
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                }
                [weatherView.activityIndicator startAnimating];
                
                /// Initiate download request
                [[SOLWundergroundDownloader sharedDownloader]dataForLocation:[locations lastObject] withTag:weatherView.tag delegate:self];
            } else {
                CZLog(@"SOLMainViewController", @"Not Updating Local Weather Data, Time Since: %f", [[NSDate date]timeIntervalSinceDate:weatherData.timestamp]);
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    CZLog(@"SOLMainViewController", @"Failed Location Update");
    
    /// If the local weather view has no data and a location could not be determined, show a failure message
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.local == YES && !weatherView.hasData) {
            weatherView.conditionIconLabel.text = @"☹";
            weatherView.conditionDescriptionLabel.text = @"Update Failed";
            weatherView.locationLabel.text = @"Check your network connection";
        }
    }
}

#pragma mark AddLocationButton Methods

- (void)addLocationButtonPressed
{
    CZLog(@"SOLMainViewController", @"Add Location Button Pressed");
    
    /// Only show the blurred overlay view if weather views have been added
    if([_pagingScrollView.subviews count] > 0) {
        [self showBlurredOverlayView:YES];
    } else {
        
        /// Fade out the logo and app name when there are no weather views
        [UIView animateWithDuration:0.3 animations: ^ {
            self->_solLogoLabel.alpha = 0.0;
            self->_solTitleLabel.alpha = 0.0;
        }];
    }
    
    /// Transition to the add location view controller
    [self presentViewController:_addLocationViewController animated:YES completion:nil];
}

#pragma mark SOLAddLocationViewControllerDelegate Methods

- (void)didAddLocationWithPlacemark:(CLPlacemark *)placemark
{
    CZLog(@"SOLMainViewController", @"Adding Weather View for Location %@", placemark.locality);
    
    /// Get cached weather data for the added placemark if it exists
    SOLWeatherData *weatherData = [self->_weatherData objectForKey:[NSNumber numberWithInteger:placemark.locality.hash]];
    
    /// Only add a location if it is does not already exist
    if(!weatherData) {
        
        /// Create a weather view for the newly added location
        SOLWeatherView *weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
        weatherView.delegate = self;
        weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kDEFAULT_BACKGROUND_GRADIENT]];
        [weatherView setLocal:NO];
        [weatherView setTag:placemark.locality.hash];
        [weatherView.activityIndicator startAnimating];
        
        self->_pageControl.numberOfPages += 1;
        [self->_pagingScrollView addSubview:weatherView];
        [self->_weatherTags addObject:[NSNumber numberWithInteger:weatherView.tag]];
        [SOLStateManager setWeatherTags:self->_weatherTags];
        
        /// Download weather data for the newly created weather view
        [[SOLWundergroundDownloader sharedDownloader]dataForPlacemark:placemark withTag:weatherView.tag delegate:self];
    }
    
    /// Hide the add location button if the number of weather views is greater than or equal to the max
    if([self->_pagingScrollView.subviews count] >= kMAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = YES;
    }
}

- (void)dismissAddLocationViewController
{
    CZLog(@"SOLMainViewController", @"Dismissing Add Location View Controller");
    [self showBlurredOverlayView:NO];
    [UIView animateWithDuration:0.3 animations: ^ {
        self->_solLogoLabel.alpha   = 1.0;
        self->_solTitleLabel.alpha  = 1.0;
    }];
    [_addLocationViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SettingsButton Methods

- (void)settingsButtonPressed
{
    CZLog(@"SOLMainViewController", @"Settings Button Pressed");
    
    /// Only show the blurred overlay view if weather views have been added
    if([_pagingScrollView.subviews count] > 0) {
        [self showBlurredOverlayView:YES];
    } else {
        
        /// Fade out the logo and app name when there are no weather views
        [UIView animateWithDuration:0.3 animations: ^ {
            self->_solLogoLabel.alpha = 0.0;
            self->_solTitleLabel.alpha = 0.0;
        }];
    }
    
    /// Prepare the data (location name, tag) needed by the settings view controller
    NSMutableArray *locations = [[NSMutableArray alloc]initWithCapacity:4];
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.tag != kLOCAL_WEATHER_VIEW_TAG) {
            NSArray *locationMetaData = @[weatherView.locationLabel.text, [NSNumber numberWithInteger:weatherView.tag]];
            [locations addObject:locationMetaData];
        }
    }
    self->_settingsViewController.locations = locations;
    
    /// Transition to the settings view controller
    [self presentViewController:_settingsViewController animated:YES completion:nil];
}

#pragma mark SOLSettingsViewControllerDelegate Methods

- (void)didMoveWeatherViewAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    CZLog(@"SOLMainViewController", @"Moved Weather Tag at Index %d to Index %d", sourceIndex, destinationIndex);
    
    NSNumber *weatherTag = [self->_weatherTags objectAtIndex:sourceIndex];
    [self->_weatherTags removeObjectAtIndex:sourceIndex];
    [self->_weatherTags insertObject:weatherTag atIndex:destinationIndex];
    
    /// Save the weather tags
    [SOLStateManager setWeatherTags:self->_weatherTags];
    
    /// If there is a local weather view, we must increment the sourceIndex and destinationIndex to
    // compensate. Checking for the local weather view's data is a simple way of checking for the local weather view
    if([self->_weatherData objectForKey:[NSNumber numberWithInteger:kLOCAL_WEATHER_VIEW_TAG]]) {
        sourceIndex +=1 ;
        destinationIndex += 1;
    }
    
    /// Move the weather view
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.tag == weatherTag.integerValue) {
            [self.pagingScrollView removeSubview:weatherView];
            [self.pagingScrollView insertSubview:weatherView atIndex:destinationIndex];
            break;
        }
    }
}

- (void)didRemoveWeatherViewWithTag:(NSInteger)tag
{
    CZLog(@"SOLMainViewController", @"Removed Weather View with Tag: %d", tag);
    
    /// Find the weather view to remove
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.tag == tag) {
            [self->_pagingScrollView removeSubview:weatherView];
            self->_pageControl.numberOfPages -= 1;
        }
    }
    
    /// Remove the associated data for the view from our saved weather data
    [self->_weatherData removeObjectForKey:[NSNumber numberWithInteger:tag]];
    
    /// Remove the associated tag for the view from our saved tag data
    [self->_weatherTags removeObject:[NSNumber numberWithInteger:tag]];
    
    /// Show the add location button if the remaining number of weather views is below the max
    if([self->_weatherData count] < kMAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = NO;
    }
    
    /// Save data
    [SOLStateManager setWeatherData:self->_weatherData];
    [SOLStateManager setWeatherTags:self->_weatherTags];
}

- (void)didChangeTemperatureScale:(SOLTemperatureScale)scale
{
    CZLog(@"SOLMainViewController", @"Changed Temperature Scale");
    
    /// Iterate through all weather views and update their temperature scales
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        SOLWeatherData *weatherData = [self->_weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
        [self updateWeatherView:weatherView withData:weatherData];
    }
}

- (void)dismissSettingsViewController
{
    CZLog(@"SOLMainViewController", @"Dismissing Settings View Controller");
    
    /// Hid the blurred overlay
    [self showBlurredOverlayView:NO];
    
    /// Show the Sol° logo
    [UIView animateWithDuration:0.3 animations: ^ {
        self->_solLogoLabel.alpha   = 1.0;
        self->_solTitleLabel.alpha  = 1.0;
    }];
    
    /// Dismiss the settings view controller
    [_settingsViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SOLWundergroundDownloaderDelegate Methods

- (void)downloadDidFailForLocation:(CLLocation *)location withTag:(NSInteger)tag
{
    CZLog(@"SOLMainViewController", @"Download failed for weather view with tag: %d", tag);
    
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.tag == tag) {
            
            /// If the weather view doesn't have any data, show a failure message
            if(!weatherView.hasData) {
                weatherView.conditionIconLabel.text = @"☹";
                weatherView.conditionDescriptionLabel.text = @"Update Failed";
                weatherView.locationLabel.text = @"Check your network connection";
            }
            
            /// Stop the weather view's activity indicator
            [weatherView.activityIndicator stopAnimating];
        }
    }
}

- (void)downloadDidFinishWithData:(SOLWeatherData *)data withTag:(NSInteger)tag
{
    CZLog(@"SOLMainViewController", @"Download finished for weather view with tag: %d", tag);
    
    for(SOLWeatherView *weatherView in self->_pagingScrollView.subviews) {
        if(weatherView.tag == tag) {
            
            /// Update the weather view with the downloaded data
            [self->_weatherData setObject:data forKey:[NSNumber numberWithInt:tag]];
            [self updateWeatherView:weatherView withData:data];
            [weatherView.activityIndicator stopAnimating];
        }
    }
    
    /// Save the downloaded data
    [SOLStateManager setWeatherData:self->_weatherData];
    if([self->_weatherData count] >= kMAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = YES;
    }
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self->_isScrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self->_isScrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self->_isScrolling = YES;
    
    /// Update the current page for the page control
    float fractionalPage = _pagingScrollView.contentOffset.x / _pagingScrollView.frame.size.width;
    _pageControl.currentPage = lround(fractionalPage);
}

#pragma mark SOLWeatherViewDelegate Methods

- (BOOL)shouldPanWeatherView
{
    /// Only allow weather views to pan if not currently scrolling
    return !self->_isScrolling;
}

- (void)didBeginPanningWeatherView
{
    /// Keep the paging scroll view from scrolling if a weather view is panning
    self->_pagingScrollView.scrollEnabled = NO;
}

- (void)didFinishPanningWeatherView
{
    /// Allow the paging scroll view to scroll if a weather view finished panning
    self->_pagingScrollView.scrollEnabled = YES;
}

@end
