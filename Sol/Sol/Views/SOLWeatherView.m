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
{
    /// Contains all label views
    UIView  *_container;
}
@end

#pragma mark - SOLWeatherView Implementation

@implementation SOLWeatherView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        /// Initialize Container
        _container = [[UIView alloc]initWithFrame:self.bounds];
        [_container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_container];
        
        /// Initialize Ribbon
        _ribbon = [[UIView alloc]initWithFrame:CGRectMake(0, 1.30 * self.center.y, self.bounds.size.width, 80)];
        [_ribbon setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [self->_container addSubview:_ribbon];
        
        /// Initialize Pan Gesture Recognizer
        self->_panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        self->_panGestureRecognizer.minimumNumberOfTouches = 1;
        self->_panGestureRecognizer.delegate = self;
        [self->_container addGestureRecognizer:self->_panGestureRecognizer];
        
        /// Initialize Activity Indicator
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.center = self.center;
        [self->_container addSubview:_activityIndicator];
        
        /// Initialize Labels
        [self initializeUpdatedLabel];
        [self initializeConditionIconLabel];
        [self initializeConditionDescriptionLabel];
        [self initializeLocationLabel];
        [self initializeCurrentTemperatureLabel];
        [self initializeHiLoTemperatureLabel];
        [self initializeForecastDayLabels];
        [self initializeForecastIconLabels];
    }
    return self;
}

#pragma mark Pan Gesture Recognizer Methods

- (void)didPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    static CGFloat initialCenterY = 0.0;
    CGPoint translatedPoint = [gestureRecognizer translationInView:self->_container];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        /// Save the inital Y to reuse later
        initialCenterY = self->_container.center.y;
        
        /// Alert the delegate that panning has begun
        [self.delegate didBeginPanningWeatherView];
        CZLog(@"SOLWeatherView", @"Did Begin Panning");
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        /// Alert the delegate that panning finished
        [self.delegate didFinishPanningWeatherView];
        
        /// Return the container back to its original position
        [UIView animateWithDuration:0.3 animations: ^ {
            self->_container.center = CGPointMake(self->_container.center.x, initialCenterY);
        }];
        CZLog(@"SOLWeatherView", @"Did End Panning");
        
    } else if(translatedPoint.y <= 50 && translatedPoint.y > 0) {
        /// Translate the container
        self->_container.center = CGPointMake(self->_container.center.x, self.center.y + translatedPoint.y);
    }
}

#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        /// We only want to register vertial pans
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self->_container];
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
    static const NSInteger fontSize = 18;
    _updatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -1.5 * fontSize, self.bounds.size.width, 1.5 * fontSize)];
    [_updatedLabel setNumberOfLines:0];
    [_updatedLabel setAdjustsFontSizeToFitWidth:YES];
    [_updatedLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [_conditionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [_updatedLabel setTextColor:[UIColor whiteColor]];
    [_updatedLabel setTextAlignment:NSTextAlignmentCenter];
    [_container addSubview:_updatedLabel];
}

- (void)initializeConditionIconLabel
{
    static const NSInteger fontSize = 180;
    _conditionIconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, fontSize)];
    [_conditionIconLabel setCenter:CGPointMake(_container.center.x, 0.5 * self.center.y)];
    [_conditionIconLabel setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
    [_conditionIconLabel setBackgroundColor:[UIColor clearColor]];
    [_conditionIconLabel setTextColor:[UIColor whiteColor]];
    [_conditionIconLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
    [_conditionIconLabel setShadowOffset:CGSizeMake(0, 1)];
    [_conditionIconLabel setTextAlignment:NSTextAlignmentCenter];
    [_container addSubview:_conditionIconLabel];
}

- (void)initializeConditionDescriptionLabel
{
    static const NSInteger fontSize = 48;
    _conditionDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0.75 * self.bounds.size.width, 1.5 * fontSize)];
    [_conditionDescriptionLabel setNumberOfLines:0];
    [_conditionDescriptionLabel setAdjustsFontSizeToFitWidth:YES];
    [_conditionDescriptionLabel setCenter:CGPointMake(_container.center.x, self.center.y)];
    [_conditionDescriptionLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [_conditionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [_conditionDescriptionLabel setTextColor:[UIColor whiteColor]];
    [_conditionDescriptionLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
    [_conditionDescriptionLabel setShadowOffset:CGSizeMake(0, 1)];
    [_conditionDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [_container addSubview:_conditionDescriptionLabel];
}

- (void)initializeLocationLabel
{
    static const NSInteger fontSize = 18;
    _locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1.5 * fontSize)];
    [_locationLabel setAdjustsFontSizeToFitWidth:YES];
    [_locationLabel setCenter:CGPointMake(_container.center.x, 1.18 * self.center.y)];
    [_locationLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [_locationLabel setBackgroundColor:[UIColor clearColor]];
    [_locationLabel setTextColor:[UIColor whiteColor]];
    [_locationLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
    [_locationLabel setShadowOffset:CGSizeMake(0, 1)];
    [_locationLabel setTextAlignment:NSTextAlignmentCenter];
    [_container addSubview:_locationLabel];
}

- (void)initializeCurrentTemperatureLabel
{
    static const NSInteger fontSize = 52;
    _currentTemperatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1.305 * self.center.y, 0.4 * self.bounds.size.width, fontSize)];
    [_currentTemperatureLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [_currentTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [_currentTemperatureLabel setTextColor:[UIColor whiteColor]];
    [_currentTemperatureLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
    [_currentTemperatureLabel setShadowOffset:CGSizeMake(0, 1)];
    [_currentTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    [_container addSubview:_currentTemperatureLabel];
}

- (void)initializeHiLoTemperatureLabel
{
    static const NSInteger fontSize = 18;
    _hiloTemperatureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [_hiloTemperatureLabel setFrame:CGRectMake(0, 0, 0.375 * self.bounds.size.width, fontSize)];
    [_hiloTemperatureLabel setCenter:CGPointMake(_currentTemperatureLabel.center.x - 4,
                                                 _currentTemperatureLabel.center.y + 0.5 * _currentTemperatureLabel.bounds.size.height + 12)];
    [_hiloTemperatureLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [_hiloTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [_hiloTemperatureLabel setTextColor:[UIColor whiteColor]];
    [_hiloTemperatureLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
    [_hiloTemperatureLabel setShadowOffset:CGSizeMake(0, 1)];
    [_hiloTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    [_container addSubview:_hiloTemperatureLabel];
}

- (void)initializeForecastDayLabels
{
    static const NSInteger fontSize = 18;
    
    _forecastDayOneLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _forecastDayTwoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _forecastDayThreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    NSArray *forecastDayLabels = @[self.forecastDayOneLabel, self.forecastDayTwoLabel, self.forecastDayThreeLabel];
    
    for(int i = 0; i < [forecastDayLabels count]; ++i) {
        UILabel *forecastDayLabel = [forecastDayLabels objectAtIndex:i];
        [forecastDayLabel setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * i), 1.33 * self.center.y, 2 * fontSize, fontSize)];
        [forecastDayLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
        [forecastDayLabel setBackgroundColor:[UIColor clearColor]];
        [forecastDayLabel setTextColor:[UIColor whiteColor]];
        [forecastDayLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
        [forecastDayLabel setShadowOffset:CGSizeMake(0, 1)];
        [forecastDayLabel setTextAlignment:NSTextAlignmentCenter];
        [self->_container addSubview:forecastDayLabel];
    }
}

- (void)initializeForecastIconLabels
{
    static const NSInteger fontSize = 40;
    
    _forecastIconOneLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _forecastIconTwoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _forecastIconThreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    
    NSArray *forecastIconLabels = @[self.forecastIconOneLabel, self.forecastIconTwoLabel, self.forecastIconThreeLabel];
    for(int i = 0; i < [forecastIconLabels count]; ++i) {
        UILabel *forecastIconLabel = [forecastIconLabels objectAtIndex:i];
        [forecastIconLabel setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * i), 1.42 * self.center.y, fontSize, fontSize)];
        [forecastIconLabel setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
        [forecastIconLabel setBackgroundColor:[UIColor clearColor]];
        [forecastIconLabel setTextColor:[UIColor whiteColor]];
        [forecastIconLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.25]];
        [forecastIconLabel setShadowOffset:CGSizeMake(0, 1)];
        [forecastIconLabel setTextAlignment:NSTextAlignmentCenter];
        [self->_container addSubview:forecastIconLabel];
    }
}

@end
