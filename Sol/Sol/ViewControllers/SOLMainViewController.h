//
//  SOLMainViewController.h
//  Sol
//
//  Created by Comyar Zaheri on 7/30/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLWundergroundDownloader.h"
#import "SOLAddLocationViewController.h"
#import "SOLSettingsViewController.h"
#import "SOLWeatherView.h"

@interface SOLMainViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate, SOLAddLocationViewControllerDelegate, SOLSettingsViewControllerDelegate, SOLWeatherViewDelegate>

// -----
// @name Updating Weather Data
// -----

/**
 Updates the weather data for all nonlocal weather views if the minimum time since
 the last update has passed.
 */
- (void)updateWeatherData;

// -----
// @name Properties
// -----

//  Location manager used to track the user's current location
@property (nonatomic, readonly) CLLocationManager   *locationManager;

@end
