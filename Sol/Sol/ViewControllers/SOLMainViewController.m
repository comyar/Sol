//
//  SOLMainViewController.m
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

#import "SOLMainViewController.h"


#pragma mark - Constants

static const CLLocationDistance locationManagerDistanceFilter = 3000.0;

//static const NSInteger maxNumWeatherViews           = 5;
//static const NSTimeInterval minTimeBetweenUpdates   = 3600.0;


#pragma mark - SOLMainViewController Class Extension

@interface SOLMainViewController () <UIPageViewControllerDataSource, CLLocationManagerDelegate>

// Location manager to get the user's current location
@property (nonatomic) CLLocationManager     *locationManager;

// Page view controller to manage weather view controllers
@property (nonatomic) UIPageViewController  *pageViewController;

// Button to present the add location view controller
@property (nonatomic) UIButton              *addLocationButton;

// Button to present the settings view controller
@property (nonatomic) UIButton              *settingsButton;

@end


#pragma mark - SOLMainViewController Implementation

@implementation SOLMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                               options:nil];
        self.locationManager = [CLLocationManager new];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = locationManagerDistanceFilter;
        self.locationManager.activityType = CLActivityTypeOther;
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.pageViewController setDataSource:self];
    [self.pageViewController willMoveToParentViewController:self];
    [self.pageViewController.view setFrame:self.view.bounds];
    [self.view addSubview:self.pageViewController.view];
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.addLocationButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addLocationButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
    self.addLocationButton.center = CGPointMake(CGRectGetWidth(self.view.bounds) - 22.0, CGRectGetHeight(self.view.bounds) - 22.0);
    [self.view addSubview:self.addLocationButton];
}

#pragma mark Buttons

- (void)didTouchUpInsideButton:(UIButton *)button
{
    if (button == self.addLocationButton) {
        
    } else if (button == self.settingsButton) {
        
    }
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        // add non local weather view controllers
        
        if (status == kCLAuthorizationStatusAuthorized) {
            // add local weather view controller
        } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
            // remove local weather view controller
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

#pragma mark UIPageViewControllerDataSource Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    return nil;
}

@end
