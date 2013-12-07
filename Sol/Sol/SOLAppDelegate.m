//
//  SOLAppDelegate.m
//  Sol
//
//  Created by Comyar Zaheri on 7/30/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLAppDelegate.h"
#import "SOLMainViewController.h"

#pragma mark - SOLAppDelegate Class Extension

@interface SOLAppDelegate ()
@property (strong, nonatomic) SOLMainViewController *mainViewController;
@end

#pragma mark - SOLAppDelegate Implementation

@implementation SOLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /// Set the status bar text color to white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    /// Initialize our app window and make it transparent (user can see the homescreen)
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    
    /// Initialize main view controller
    self.mainViewController = [[SOLMainViewController alloc]initWithNibName:nil bundle:nil];
    
    /// Initialize and configure the location manager and start updating the user's current location
    self.mainViewController.locationManager = [[CLLocationManager alloc]init];
    self.mainViewController.locationManager.delegate = self->_mainViewController;
    self.mainViewController.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.mainViewController.locationManager.distanceFilter = 3000;
    [self.mainViewController.locationManager startUpdatingLocation];
    
    /// Set our window's root view controller and make the app window visible
    self.window.rootViewController = self->_mainViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /// Make sure any changes to userdefaults are saved to disk
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    /// Stop updating the user's location
    [self.mainViewController.locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /// Begin updating the user's location again
    [self.mainViewController.locationManager startUpdatingLocation];
    [self.mainViewController updateWeatherData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /// Begin updating the user's location again
    [self.mainViewController.locationManager startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /// Make sure any changes to userdefaults are saved to disk
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
