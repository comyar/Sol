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

/** Constants */
#define kMIN_TIME_SINCE_UPDATE          3600
#define kMAX_NUM_WEATHER_VIEWS          5
#define kLOCAL_WEATHER_VIEW_TAG         0
#define kDEFAULT_BACKGROUND_GRADIENT    @"gradient5"


#pragma mark - SOLMainViewController Class Extension

@interface SOLMainViewController ()

//  Redefinition of location manager
@property (strong, nonatomic) CLLocationManager     *locationManager;

//  Dictionary of all weather data being managed by the app
@property (strong, nonatomic) NSMutableDictionary   *weatherData;

//  Ordered-List of weather tags
@property (strong, nonatomic) NSMutableArray        *weatherTags;

//  Formats weather data timestamps
@property (strong, nonatomic) NSDateFormatter       *dateFormatter;

@property (assign, nonatomic) BOOL                  isScrolling;

// -----
// @name View Controllers
// -----

//  View controller for changing settings
@property (strong, nonatomic) SOLSettingsViewController     *settingsViewController;

//  View controller for adding new locations
@property (strong, nonatomic) SOLAddLocationViewController  *addLocationViewController;

// -----
// @name Subviews
// -----

//  Dark, semi-transparent view to sit above the homescreen
@property (strong, nonatomic) UIView              *darkenedBackgroundView;

//  Label displaying the Sol° logo
@property (strong, nonatomic) UILabel             *solLogoLabel;

//  Label displaying the name of the app
@property (strong, nonatomic) UILabel             *solTitleLabel;

//  Contains blurred screenshots of this controller's view when transitioning to another controller
@property (strong, nonatomic)  UIImageView        *blurredOverlayView;

//  Buton used to transition to the settings view controller
@property (strong, nonatomic) UIButton            *settingsButton;

//  Button used to transition to the add location view controller
@property (strong, nonatomic) UIButton            *addLocationButton;

//  Page control displaying the number of pages managed by the paging scroll view
@property (strong, nonatomic) UIPageControl       *pageControl;

//  Paging scroll view to manage weather views
@property (strong, nonatomic) SOLPagingScrollView *pagingScrollView;

@end


#pragma mark - SOLMainViewController Implementation

@implementation SOLMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        //  Initialize the weather data dictionary with saved data, if it exists
        NSDictionary *savedWeatherData = [SOLStateManager weatherData];
        if(savedWeatherData) {
            self.weatherData = [NSMutableDictionary dictionaryWithDictionary:savedWeatherData];
        } else {
            self.weatherData = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        
        //  Initialize the weather tags array with saved data, if it exists
        NSArray *savedWeatherTags = [SOLStateManager weatherTags];
        if(savedWeatherTags) {
            self.weatherTags = [NSMutableArray arrayWithArray:savedWeatherTags];
        } else {
            self.weatherTags = [NSMutableArray arrayWithCapacity:4];
        }
        
        //  Configure Date Formatter
        self.dateFormatter = [[NSDateFormatter alloc]init];
        [self.dateFormatter setDateFormat:@"EEE MMM d, h:mm a"];
        
        //  Initialize and configure the location manager and start updating the user's current location
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = 3000;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        //  Initialize other properties
        [self initializeViewControllers];
        [self initializeSubviews];
        [self initializeSettingsButton];
        [self initializeAddLocationButton];
        
        //  Hide add location button if we have reached the maximum number of views
        if([self.weatherData count] >= kMAX_NUM_WEATHER_VIEWS) {
            self.addLocationButton.hidden = YES;
        }
        
        //  The blurred overlay view should sit in front of all other subviews
        [self.view bringSubviewToFront:self.blurredOverlayView];
    }
    return self;
}

- (void)initializeViewControllers
{
    //  Initialize the add location view controller
    self.addLocationViewController = [[SOLAddLocationViewController alloc]init];
    self.addLocationViewController.delegate = self;
    
    //  Initialize the settings view controller
    self.settingsViewController = [[SOLSettingsViewController alloc]init];
    self.settingsViewController.delegate = self;
}

- (void)initializeSubviews
{
    //  Initialize the darkended background view
    self.darkenedBackgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.darkenedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:self.darkenedBackgroundView];
    
    //  Initialize the Sol° logo label
    self.solLogoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 160)];
    self.solLogoLabel.center = CGPointMake(self.view.center.x, 0.5 * self.view.center.y);
    self.solLogoLabel.font = [UIFont fontWithName:CLIMACONS_FONT size:200];
    self.solLogoLabel.backgroundColor = [UIColor clearColor];
    self.solLogoLabel.textColor = [UIColor whiteColor];
    self.solLogoLabel.textAlignment = NSTextAlignmentCenter;
    self.solLogoLabel.text = [NSString stringWithFormat:@"%c", ClimaconSun];
    [self.view addSubview:self.solLogoLabel];

    //  Initialize the Sol° title label
    self.solTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
    self.solTitleLabel.center = self.view.center;
    self.solTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:64];
    self.solTitleLabel.backgroundColor = [UIColor clearColor];
    self.solTitleLabel.textColor = [UIColor whiteColor];
    self.solTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.solTitleLabel.text = @"Sol°";
    [self.view addSubview:self.solTitleLabel];

    //  Initialize the paging scroll wiew
    self.pagingScrollView = [[SOLPagingScrollView alloc]initWithFrame:self.view.bounds];
    self.pagingScrollView.delegate = self;
    self.pagingScrollView.bounces = NO;
    [self.view addSubview:self.pagingScrollView];
    
    //  Initialize the page control
    self.pageControl = [[UIPageControl alloc]initWithFrame: CGRectMake(0, CGRectGetHeight(self.view.bounds) - 32,
                                                                       CGRectGetWidth(self.view.bounds), 32)];
    [self.pageControl setHidesForSinglePage:YES];
    [self.view addSubview:self.pageControl];
    
    //  Initialize the blurred overlay view
    self.blurredOverlayView = [[UIImageView alloc]initWithImage:[[UIImage alloc]init]];
    self.blurredOverlayView.alpha = 0.0;
    [self.blurredOverlayView setFrame:self.view.bounds];
    [self.view addSubview:self.blurredOverlayView];
}

- (void)initializeAddLocationButton
{
    self.addLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *plusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [plusLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:40]];
    [plusLabel setTextAlignment:NSTextAlignmentCenter];
    [plusLabel setTextColor:[UIColor whiteColor]];
    [plusLabel setText:@"+"];
    [self.addLocationButton addSubview:plusLabel];
    [self.addLocationButton setFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 44, CGRectGetHeight(self.view.bounds) - 54, 44, 44)];
    [self.addLocationButton setShowsTouchWhenHighlighted:YES];
    [self.addLocationButton addTarget:self action:@selector(addLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addLocationButton];
}

- (void)initializeSettingsButton
{
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [self.settingsButton setTintColor:[UIColor whiteColor]];
    [self.settingsButton setFrame:CGRectMake(4, CGRectGetHeight(self.view.bounds) - 48, 44, 44)];
    [self.settingsButton setShowsTouchWhenHighlighted:YES];
    [self.settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
}

- (void)initializeLocalWeatherView
{
    SOLWeatherView *localWeatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
    localWeatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kDEFAULT_BACKGROUND_GRADIENT]];
    localWeatherView.local = YES;
    localWeatherView.delegate = self;
    localWeatherView.tag = kLOCAL_WEATHER_VIEW_TAG;
    [self.pagingScrollView addSubview:localWeatherView];
    self.pageControl.numberOfPages += 1;
    
    SOLWeatherData *localWeatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:kLOCAL_WEATHER_VIEW_TAG]];
    if(localWeatherData) {
        [self updateWeatherView:localWeatherView withData:localWeatherData];
    }
}

- (void)initializeNonlocalWeatherViews
{
    for(NSNumber *tagNumber in self.weatherTags) {
        //  Initialize a new weather view for all weather data not belonging to the local weather view
        SOLWeatherData *weatherData = [self.weatherData objectForKey:tagNumber];
        if(weatherData) {
            SOLWeatherView *weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
            weatherView.delegate = self;
            weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient5.png"]];
            weatherView.tag = tagNumber.integerValue;
            weatherView.local = NO;
            self.pageControl.numberOfPages += 1;
            [self.pagingScrollView addSubview:weatherView isLaunch:YES];
            [self updateWeatherView:weatherView withData:weatherData];
        }
    }
}

#pragma mark Using a SOLMainViewController

- (void)showBlurredOverlayView:(BOOL)show
{
    [UIView animateWithDuration:0.25 animations: ^ {
        self.blurredOverlayView.alpha = (show)? 1.0 : 0.0;;
    }];
}

- (void)setBlurredOverlayImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        
        //  Take a screen shot of this controller's view
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self.view.layer renderInContext:context];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        //  Blur the screen shot
        UIImage *blurred = [image applyBlurWithRadius:20
                                            tintColor:[UIColor colorWithWhite:0.15 alpha:0.5]
                                saturationDeltaFactor:1.5
                                            maskImage:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            //  Set the blurred overlay view's image with the blurred screenshot
            self.blurredOverlayView.image = blurred;
        });
    });
}

#pragma mark Updating Weather Data

- (void)updateWeatherData
{
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.local == NO) {
            
            //  Only update non local weather data
            SOLWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            
            //  Only update if the minimum time for updates has passed
            if([[NSDate date]timeIntervalSinceDate:weatherData.timestamp] >= kMIN_TIME_SINCE_UPDATE || !weatherView.hasData) {
                
                //  If the weather view is already showing data, we need to move the activity indicator
                if(weatherView.hasData) {
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                }
                [weatherView.activityIndicator startAnimating];
                
                //  Make the data download request, Block based
                [[SOLWundergroundDownloader sharedDownloader]dataForPlacemark:weatherData.placemark
                                                                      withTag:weatherView.tag
                                                                   completion: ^ (SOLWeatherData *data, NSError *error) {
                    if (data) {
                        // Success
                        [self downloadDidFinishWithData:data withTag:weatherView.tag];
                    } else {
                        // Failure
                        [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                    }
                    [self setBlurredOverlayImage];
                }];
                
            }
        }
    }
}

- (void)downloadDidFailForWeatherViewWithTag:(NSInteger)tag
{
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.tag == tag) {
            
            //  If the weather view doesn't have any data, show a failure message
            if(!weatherView.hasData) {
                weatherView.conditionIconLabel.text = @"☹";
                weatherView.conditionDescriptionLabel.text = @"Update Failed";
                weatherView.locationLabel.text = @"Check your network connection";
            }
            
            //  Stop the weather view's activity indicator
            [weatherView.activityIndicator stopAnimating];
        }
    }
}

- (void)downloadDidFinishWithData:(SOLWeatherData *)data withTag:(NSInteger)tag
{
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.tag == tag) {
            [self.weatherData setObject:data forKey:[NSNumber numberWithInteger:tag]];
            
            //  Update the weather view with the downloaded data
            [self updateWeatherView:weatherView withData:data];
            [weatherView.activityIndicator stopAnimating];
        }
    }
    
    //  Save the downloaded data
    [SOLStateManager setWeatherData:self.weatherData];
    if([self.weatherData count] >= kMAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = YES;
    }
}

- (void)updateWeatherView:(SOLWeatherView *)weatherView withData:(SOLWeatherData *)data
{
    if(!data) {
        return;
    }
    
    weatherView.hasData = YES;
    
    //  Set the update time
    weatherView.updatedLabel.text = [NSString stringWithFormat:@"Updated %@", [self.dateFormatter stringFromDate:data.timestamp]];
    
    //  Set the current condition icon and description
    weatherView.conditionIconLabel.text         = data.currentSnapshot.icon;
    weatherView.conditionDescriptionLabel.text  = data.currentSnapshot.conditionDescription;
    
    //  Only show the country name if not the United States
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
    
    //  Set the temperature labels depending on the current scale set in the settings
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
    
    //  Set the weather view's forcast day labels
    weatherView.forecastDayOneLabel.text    = [forecastDayOneSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
    weatherView.forecastDayTwoLabel.text    = [forecastDayTwoSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
    weatherView.forecastDayThreeLabel.text  = [forecastDayThreeSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
    
    //  Set the weather view's forecast icons
    weatherView.forecastIconOneLabel.text   = forecastDayOneSnapshot.icon;
    weatherView.forecastIconTwoLabel.text   = forecastDayTwoSnapshot.icon;
    weatherView.forecastIconThreeLabel.text = forecastDayThreeSnapshot.icon;
    
    //  Set the weather view's background color
    CGFloat fahrenheit = MIN(MAX(0, currentTemperature.fahrenheit), 99);
    NSString *gradientImageName = [NSString stringWithFormat:@"gradient%d.png", (int)floor(fahrenheit / 10.0)];
    weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:gradientImageName]];
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //  Only add the local weather view if location services authorized
    if(status == kCLAuthorizationStatusAuthorized) {
        [self initializeLocalWeatherView];
        [self initializeNonlocalWeatherViews];
        [self setBlurredOverlayImage];
        [self updateWeatherData];
    } else if(status != kCLAuthorizationStatusNotDetermined) {
        [self initializeNonlocalWeatherViews];
        [self setBlurredOverlayImage];
        [self updateWeatherData];
    } else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        //  If location services are disabled and no saved weather data is found, show the add location view controller
        if([self.pagingScrollView.subviews count] == 0) {
            [self presentViewController:self.addLocationViewController animated:YES completion:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //  Download new weather data for the local weather view
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.local == YES) {
            SOLWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            
            //  Only update weather data if the time since last update has exceeded the minimum time
            if([[NSDate date]timeIntervalSinceDate:weatherData.timestamp] >= kMIN_TIME_SINCE_UPDATE || !weatherView.hasData) {
                //  If the weather view has data, move the activity indicator to not overall with any labels
                if(weatherView.hasData) {
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                }
                [weatherView.activityIndicator startAnimating];
                
                //  Initiate download request
                [[SOLWundergroundDownloader sharedDownloader]dataForLocation:[locations lastObject] withTag:weatherView.tag completion:^(SOLWeatherData *data, NSError *error) {
                    
                    if (data) {
                        // Success
                        [self downloadDidFinishWithData:data withTag:weatherView.tag];
                    } else {
                        // Failure
                        [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                    }
                }];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //  If the local weather view has no data and a location could not be determined, show a failure message
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
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
    //  Only show the blurred overlay view if weather views have been added
    if([self.pagingScrollView.subviews count] > 0) {
        [self showBlurredOverlayView:YES];
    } else {
        
        //  Fade out the logo and app name when there are no weather views
        [UIView animateWithDuration:0.3 animations: ^ {
            self.solLogoLabel.alpha = 0.0;
            self.solTitleLabel.alpha = 0.0;
        }];
    }
    
    //  Transition to the add location view controller
    [self presentViewController:self.addLocationViewController animated:YES completion:nil];
}

#pragma mark SOLAddLocationViewControllerDelegate Methods

- (void)didAddLocationWithPlacemark:(CLPlacemark *)placemark
{
    //  Get cached weather data for the added placemark if it exists
    SOLWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:placemark.locality.hash]];
    
    //  Only add a location if it is does not already exist
    if(!weatherData) {
        
        //  Create a weather view for the newly added location
        SOLWeatherView *weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
        weatherView.delegate = self;
        weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kDEFAULT_BACKGROUND_GRADIENT]];
        [weatherView setLocal:NO];
        [weatherView setTag:placemark.locality.hash];
        [weatherView.activityIndicator startAnimating];

        self.pageControl.numberOfPages += 1;
        [self.pagingScrollView addSubview:weatherView isLaunch:NO];
        [self.weatherTags addObject:[NSNumber numberWithInteger:weatherView.tag]];
        [SOLStateManager setWeatherTags:self.weatherTags];
        
        //  Download weather data for the newly created weather view
        [[SOLWundergroundDownloader sharedDownloader]dataForPlacemark:placemark withTag:weatherView.tag completion:^(SOLWeatherData *data, NSError *error) {
            if (data) {
                // Success
                [self downloadDidFinishWithData:data withTag:weatherView.tag];
            } else {
                // Failure
                [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
            }
            [self setBlurredOverlayImage];
        }];
    }
    
    //  Hide the add location button if the number of weather views is greater than or equal to the max
    if([self.pagingScrollView.subviews count] >= kMAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = YES;
    }
}

- (void)dismissAddLocationViewController
{
    [self showBlurredOverlayView:NO];
    [UIView animateWithDuration:0.3 animations: ^ {
        self.solLogoLabel.alpha   = 1.0;
        self.solTitleLabel.alpha  = 1.0;
    }];
    [self.addLocationViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SettingsButton Methods

- (void)settingsButtonPressed
{
    //  Prepare the data (location name, tag) needed by the settings view controller
    NSMutableArray *locations = [[NSMutableArray alloc]initWithCapacity:4];
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.tag != kLOCAL_WEATHER_VIEW_TAG) {
            NSArray *locationMetaData = @[weatherView.locationLabel.text, [NSNumber numberWithInteger:weatherView.tag]];
            [locations addObject:locationMetaData];
        }
    }
    
    self.settingsViewController.locations = locations;
    
    //  Transition to the settings view controller
    [self presentViewController:self.settingsViewController animated:YES completion:nil];
    
    //  Only show the blurred overlay view if weather views have been added
    if([self.pagingScrollView.subviews count] > 0) {
        [self showBlurredOverlayView:YES];
    } else {
        
        //  Fade out the logo and app name when there are no weather views
        [UIView animateWithDuration:0.3 animations: ^ {
            self.solLogoLabel.alpha = 0.0;
            self.solTitleLabel.alpha = 0.0;
        }];
    }
}

#pragma mark SOLSettingsViewControllerDelegate Methods

- (void)didMoveWeatherViewAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    NSNumber *weatherTag = [self.weatherTags objectAtIndex:sourceIndex];
    [self.weatherTags removeObjectAtIndex:sourceIndex];
    [self.weatherTags insertObject:weatherTag atIndex:destinationIndex];
    
    //  Save the weather tags
    [SOLStateManager setWeatherTags:self.weatherTags];
    
    //  If there is a local weather view, we must increment the sourceIndex and destinationIndex to
    // compensate. Checking for the local weather view's data is a simple way of checking for the local weather view
    if([self.weatherData objectForKey:[NSNumber numberWithInteger:kLOCAL_WEATHER_VIEW_TAG]]) {
        destinationIndex += 1;
    }
    
    //  Move the weather view
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.tag == weatherTag.integerValue) {
            [self.pagingScrollView removeSubview:weatherView];
            [self.pagingScrollView insertSubview:weatherView atIndex:destinationIndex];
            break;
        }
    }
}

- (void)didRemoveWeatherViewWithTag:(NSInteger)tag
{
    //  Find the weather view to remove
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.tag == tag) {
            [self.pagingScrollView removeSubview:weatherView];
            self.pageControl.numberOfPages -= 1;
        }
    }
    
    //  Remove the associated data for the view from our saved weather data
    [self.weatherData removeObjectForKey:[NSNumber numberWithInteger:tag]];
    
    //  Remove the associated tag for the view from our saved tag data
    [self.weatherTags removeObject:[NSNumber numberWithInteger:tag]];
    
    //  Show the add location button if the remaining number of weather views is below the max
    if([self.weatherData count] < kMAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = NO;
    }
    
    //  Save data
    [SOLStateManager setWeatherData:self.weatherData];
    [SOLStateManager setWeatherTags:self.weatherTags];
}

- (void)didChangeTemperatureScale:(SOLTemperatureScale)scale
{
    //  Iterate through all weather views and update their temperature scales
    for(SOLWeatherView *weatherView in self.pagingScrollView.subviews) {
        SOLWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
        [self updateWeatherView:weatherView withData:weatherData];
    }
}

- (void)dismissSettingsViewController
{
    //  Hid the blurred overlay
    [self showBlurredOverlayView:NO];
    
    //  Show the Sol° logo
    [UIView animateWithDuration:0.3 animations: ^ {
        self.solLogoLabel.alpha   = 1.0;
        self.solTitleLabel.alpha  = 1.0;
    }];
    
    //  Dismiss the settings view controller
    [self.settingsViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isScrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
    [self setBlurredOverlayImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
    
    //  Update the current page for the page control
    float fractionalPage = self.pagingScrollView.contentOffset.x / self.pagingScrollView.frame.size.width;
    self.pageControl.currentPage = lround(fractionalPage);
}

#pragma mark SOLWeatherViewDelegate Methods

- (BOOL)shouldPanWeatherView
{
    //  Only allow weather views to pan if not currently scrolling
    return !self.isScrolling;
}

- (void)didBeginPanningWeatherView
{
    //  Keep the paging scroll view from scrolling if a weather view is panning
    self.pagingScrollView.scrollEnabled = NO;
}

- (void)didFinishPanningWeatherView
{
    //  Allow the paging scroll view to scroll if a weather view finished panning
    self.pagingScrollView.scrollEnabled = YES;
}

@end
