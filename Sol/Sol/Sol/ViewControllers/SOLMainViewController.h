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

@class SOLPagingScrollView;

@interface SOLMainViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate, SOLWundergroundDownloaderDelegate, SOLAddLocationViewControllerDelegate, SOLSettingsViewControllerDelegate, SOLWeatherViewDelegate>
{
    /// View controller for changing settings
    SOLSettingsViewController       *_settingsViewController;
    
    /// View controller for adding new locations
    SOLAddLocationViewController    *_addLocationViewController;
}

/////////////////////////////////////////////////////////////////////////////
/// @name Updating Weather Data
/////////////////////////////////////////////////////////////////////////////

/**
 Updates the weather data for all nonlocal weather views if the minimum time since
 the last update has passed.
 */
- (void)updateWeatherData;

/////////////////////////////////////////////////////////////////////////////
/// @name Properties
/////////////////////////////////////////////////////////////////////////////

/// Location manager used to track the user's current location
@property (strong, nonatomic)           CLLocationManager   *locationManager;

/// Buton used to transition to the settings view controller
@property (strong, nonatomic, readonly) UIButton            *settingsButton;

/// Button used to transition to the add location view controller
@property (strong, nonatomic, readonly) UIButton            *addLocationButton;

/// Page control displaying the number of pages managed by the paging scroll view
@property (strong, nonatomic, readonly) UIPageControl       *pageControl;

/// Paging scroll view to manage 
@property (strong, nonatomic, readonly) SOLPagingScrollView *pagingScrollView;

@end
