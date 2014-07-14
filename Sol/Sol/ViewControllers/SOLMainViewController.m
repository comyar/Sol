//
//  SOLMainViewController.m
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

#import "SOLMainViewController.h"
#import "SOLStateManager.h"


#pragma mark - Constants

//static const NSInteger maxNumWeatherViews           = 5;
//static const NSTimeInterval minTimeBetweenUpdates   = 3600.0;


#pragma mark - SOLMainViewController Class Extension

@interface SOLMainViewController () <UIPageViewControllerDataSource>

// Page view controller to manage weather view controllers
@property (strong, nonatomic) UIPageViewController          *pageViewController;

@end


#pragma mark - SOLMainViewController Implementation

@implementation SOLMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                               options:nil];
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
    
}

#pragma mark Using a SOLMainViewController


- (void)updateWeatherView:(SOLWeatherView *)weatherView withData:(SOLWeatherData *)data
{
//    if(!data) {
//        return;
//    }
//    
//    weatherView.hasData = YES;
//    
//    //  Set the update time
//    weatherView.updatedLabel.text = [NSString stringWithFormat:@"Updated %@", [self.dateFormatter stringFromDate:data.timestamp]];
//    
//    //  Set the current condition icon and description
//    weatherView.conditionIconLabel.text         = data.currentSnapshot.icon;
//    weatherView.conditionDescriptionLabel.text  = data.currentSnapshot.conditionDescription;
//    
//    //  Only show the country name if not the United States
//    NSString *city      = data.placemark.locality;
//    NSString *state     = data.placemark.administrativeArea;
//    NSString *country   = data.placemark.country;
//    if([[country lowercaseString] isEqualToString:@"united states"]) {
//        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
//    } else {
//        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, country];
//    }
//    
//    SOLTemperature currentTemperature   = data.currentSnapshot.currentTemperature;
//    SOLTemperature highTemperature      = data.currentSnapshot.highTemperature;
//    SOLTemperature lowTemperature       = data.currentSnapshot.lowTemperature;
//    
//    //  Set the temperature labels depending on the current scale set in the settings
//    if([SOLStateManager temperatureScale] == SOLFahrenheitScale) {
//        weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", currentTemperature.fahrenheit];
//        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", highTemperature.fahrenheit, lowTemperature.fahrenheit];
//    } else {
//        weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", currentTemperature.celsius];
//        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", highTemperature.celsius, lowTemperature.celsius];
//    }
//    
//    SOLWeatherSnapshot *forecastDayOneSnapshot      = [data.forecastSnapshots objectAtIndex:0];
//    SOLWeatherSnapshot *forecastDayTwoSnapshot      = [data.forecastSnapshots objectAtIndex:1];
//    SOLWeatherSnapshot *forecastDayThreeSnapshot    = [data.forecastSnapshots objectAtIndex:2];
//    
//    //  Set the weather view's forcast day labels
//    weatherView.forecastDayOneLabel.text    = [forecastDayOneSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
//    weatherView.forecastDayTwoLabel.text    = [forecastDayTwoSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
//    weatherView.forecastDayThreeLabel.text  = [forecastDayThreeSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
//    
//    //  Set the weather view's forecast icons
//    weatherView.forecastIconOneLabel.text   = forecastDayOneSnapshot.icon;
//    weatherView.forecastIconTwoLabel.text   = forecastDayTwoSnapshot.icon;
//    weatherView.forecastIconThreeLabel.text = forecastDayThreeSnapshot.icon;
//    
//    //  Set the weather view's background color
//    CGFloat fahrenheit = MIN(MAX(0, currentTemperature.fahrenheit), 99);
//    NSString *gradientImageName = [NSString stringWithFormat:@"gradient%d.png", (int)floor(fahrenheit / 10.0)];
//    weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:gradientImageName]];
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
