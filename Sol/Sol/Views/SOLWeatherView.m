//
//  SOLWeatherView.m
//  Sol
//
//  Created by Comyar Zaheri on 8/3/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//


#import "SOLWeatherView.h"

#define LIGHT_FONT      @"HelveticaNeue-Light"
#define ULTRALIGHT_FONT @"HelveticaNeue-UltraLight"


#pragma mark - SOLWeatherView Class Extension

@interface SOLWeatherView ()

//  Contains all label views
@property (strong, nonatomic) UIView                    *container;

//  Light-Colored ribbon to display temperatures and forecasts on
@property (strong, nonatomic) UIView                    *ribbon;

//  Used to drag the weather view content vertically
@property (strong, nonatomic) UIPanGestureRecognizer    *panGestureRecognizer;

//  Displays the time the weather data for this view was last updated
@property (strong, nonatomic) UILabel                   *updatedLabel;

//  Displays the icon for current conditions
@property (strong, nonatomic) UILabel                   *conditionIconLabel;

//  Displays the description of current conditions
@property (strong, nonatomic) UILabel                   *conditionDescriptionLabel;

//  Displays the location whose weather data is being represented by this weather view
@property (strong, nonatomic) UILabel                   *locationLabel;

//  Displayes the current temperature
@property (strong, nonatomic) UILabel                   *currentTemperatureLabel;

//  Displays both the high and low temperatures for today
@property (strong, nonatomic) UILabel                   *hiloTemperatureLabel;

//  Displays the day of the week for the first forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastDayOneLabel;

//  Displays the day of the week for the second forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastDayTwoLabel;

//  Displays the day of the week for the third forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastDayThreeLabel;

//  Displays the icon representing the predicted conditions for the first forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastIconOneLabel;

//  Displays the icon representing the predicted conditions for the second forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastIconTwoLabel;

//  Displays the icon representing the predicted conditions for the third forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastIconThreeLabel;

//  Indicates whether data is being downloaded for this weather view
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

@end


#pragma mark - SOLWeatherView Implementation

@implementation SOLWeatherView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        //  Initialize Container
        self.container = [[UIView alloc]initWithFrame:self.bounds];
        [self.container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.container];
        
        //  Initialize Ribbon
        self.ribbon = [[UIView alloc]initWithFrame:CGRectMake(0, 1.30 * self.center.y, self.bounds.size.width, 80)];
        [self.ribbon setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [self.container addSubview:self.ribbon];
        
        //  Initialize Pan Gesture Recognizer
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        self.panGestureRecognizer.minimumNumberOfTouches = 1;
        self.panGestureRecognizer.delegate = self;
        [self.container addGestureRecognizer:self.panGestureRecognizer];
        
        //  Initialize Activity Indicator
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.center = self.center;
        [self.container addSubview:self.activityIndicator];
        
        //  Initialize Labels
        [self initializeUpdatedLabel];
        [self initializeConditionIconLabel];
        [self initializeConditionDescriptionLabel];
        [self initializeLocationLabel];
        [self initializeCurrentTemperatureLabel];
        [self initializeHiLoTemperatureLabel];
        [self initializeForecastDayLabels];
        [self initializeForecastIconLabels];
        [self initializeMotionEffects];
    }
    return self;
}

#pragma mark Motion Effects

- (void)initializeMotionEffects
{
    UIInterpolatingMotionEffect *verticalInterpolation = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalInterpolation.minimumRelativeValue = @(-15);
    verticalInterpolation.maximumRelativeValue = @(15);
    
    UIInterpolatingMotionEffect *horizontalInterpolation = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalInterpolation.minimumRelativeValue = @(-15);
    horizontalInterpolation.maximumRelativeValue = @(15);
    
    [self.conditionIconLabel addMotionEffect:verticalInterpolation];
    [self.conditionIconLabel addMotionEffect:horizontalInterpolation];
}

#pragma mark Pan Gesture Recognizer Methods

- (void)didPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    static CGFloat initialCenterY = 0.0;
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.container];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //  Save the inital Y to reuse later
        initialCenterY = self.container.center.y;
        
        //  Alert the delegate that panning has begun
        [self.delegate didBeginPanningWeatherView];
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        //  Alert the delegate that panning finished
        [self.delegate didFinishPanningWeatherView];
        
        //  Return the container back to its original position
        [UIView animateWithDuration:0.3 animations: ^ {
            self.container.center = CGPointMake(self.container.center.x, initialCenterY);
        }];
        
    } else if(translatedPoint.y <= 50 && translatedPoint.y > 0) {
        //  Translate the container
        self.container.center = CGPointMake(self.container.center.x, self.center.y + translatedPoint.y);
    }
}

#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        //  We only want to register vertial pans
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self.container];
        return fabsf(velocity.y) > fabsf(velocity.x);
    }
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark Label Initialization Methods

- (void)initializeUpdatedLabel
{
    static const NSInteger fontSize = 16;
    self.updatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -1.5 * fontSize, self.bounds.size.width, 1.5 * fontSize)];
    [self.updatedLabel setNumberOfLines:0];
    [self.updatedLabel setAdjustsFontSizeToFitWidth:YES];
    [self.updatedLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.updatedLabel setTextColor:[UIColor whiteColor]];
    [self.updatedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.updatedLabel];
}

- (void)initializeConditionIconLabel
{
    const NSInteger fontSize = 180;
    self.conditionIconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, fontSize)];
    [self.conditionIconLabel setCenter:CGPointMake(self.container.center.x, 0.5 * self.center.y)];
    [self.conditionIconLabel setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
    [self.conditionIconLabel setBackgroundColor:[UIColor clearColor]];
    [self.conditionIconLabel setTextColor:[UIColor whiteColor]];
    [self.conditionIconLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.conditionIconLabel];
}

- (void)initializeConditionDescriptionLabel
{
    const NSInteger fontSize = 48;
    self.conditionDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0.75 * self.bounds.size.width, 1.5 * fontSize)];
    [self.conditionDescriptionLabel setNumberOfLines:0];
    [self.conditionDescriptionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.conditionDescriptionLabel setCenter:CGPointMake(self.container.center.x, self.center.y)];
    [self.conditionDescriptionLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [self.conditionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [self.conditionDescriptionLabel setTextColor:[UIColor whiteColor]];
    [self.conditionDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.conditionDescriptionLabel];
}

- (void)initializeLocationLabel
{
    const NSInteger fontSize = 18;
    self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1.5 * fontSize)];
    [self.locationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.locationLabel setCenter:CGPointMake(self.container.center.x, 1.18 * self.center.y)];
    [self.locationLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.locationLabel setBackgroundColor:[UIColor clearColor]];
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    [self.locationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.locationLabel];
}

- (void)initializeCurrentTemperatureLabel
{
    const NSInteger fontSize = 52;
    self.currentTemperatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1.305 * self.center.y, 0.4 * self.bounds.size.width, fontSize)];
    [self.currentTemperatureLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [self.currentTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [self.currentTemperatureLabel setTextColor:[UIColor whiteColor]];
    [self.currentTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.currentTemperatureLabel];
}

- (void)initializeHiLoTemperatureLabel
{
    const NSInteger fontSize = 18;
    self.hiloTemperatureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self.hiloTemperatureLabel setFrame:CGRectMake(0, 0, 0.375 * self.bounds.size.width, fontSize)];
    [self.hiloTemperatureLabel setCenter:CGPointMake(self.currentTemperatureLabel.center.x - 4,
                                                 self.currentTemperatureLabel.center.y + 0.5 * self.currentTemperatureLabel.bounds.size.height + 12)];
    [self.hiloTemperatureLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.hiloTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [self.hiloTemperatureLabel setTextColor:[UIColor whiteColor]];
    [self.hiloTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.hiloTemperatureLabel];
}

- (void)initializeForecastDayLabels
{
    const NSInteger fontSize = 18;
    
    self.forecastDayOneLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.forecastDayTwoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.forecastDayThreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    NSArray *forecastDayLabels = @[self.forecastDayOneLabel, self.forecastDayTwoLabel, self.forecastDayThreeLabel];
    
    for(int i = 0; i < [forecastDayLabels count]; ++i) {
        UILabel *forecastDayLabel = [forecastDayLabels objectAtIndex:i];
        [forecastDayLabel setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * i), 1.33 * self.center.y, 2 * fontSize, fontSize)];
        [forecastDayLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
        [forecastDayLabel setBackgroundColor:[UIColor clearColor]];
        [forecastDayLabel setTextColor:[UIColor whiteColor]];
        [forecastDayLabel setTextAlignment:NSTextAlignmentCenter];
        [self.container addSubview:forecastDayLabel];
    }
}

- (void)initializeForecastIconLabels
{
    const NSInteger fontSize = 40;
    
    self.forecastIconOneLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.forecastIconTwoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.forecastIconThreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    
    NSArray *forecastIconLabels = @[self.forecastIconOneLabel, self.forecastIconTwoLabel, self.forecastIconThreeLabel];
    for(int i = 0; i < [forecastIconLabels count]; ++i) {
        UILabel *forecastIconLabel = [forecastIconLabels objectAtIndex:i];
        [forecastIconLabel setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * i), 1.42 * self.center.y, fontSize, fontSize)];
        [forecastIconLabel setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
        [forecastIconLabel setBackgroundColor:[UIColor clearColor]];
        [forecastIconLabel setTextColor:[UIColor whiteColor]];
        [forecastIconLabel setTextAlignment:NSTextAlignmentCenter];
        [self.container addSubview:forecastIconLabel];
    }
}

@end
