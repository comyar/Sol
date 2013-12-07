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
/// The initial view controller presented to the user
@property (strong, nonatomic) SOLMainViewController *mainViewController;
@end

#pragma mark - SOLAppDelegate Implementation

@implementation SOLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /// Set the status bar text color to white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    /// Initialize our app window and make it transparent (user can see the homescreen)
    /// NOTE: Transparency isn't visible unless UIApplicationIsOpaque is set to NO in plist (private API)
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    
    /// Initialize main view controller
    self.mainViewController = [[SOLMainViewController alloc]initWithNibName:nil bundle:nil];
    
    /// Set our window's root view controller and make the app window visible
    self.window.rootViewController = self.mainViewController;
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
