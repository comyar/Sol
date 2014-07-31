//
//  SOLWeatherViewController.m
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

#import "SOLWeatherViewController.h"
#import "SOLWeatherView.h"
#import "SOLKeyManager.h"
#import "SOLWeatherViewModel.h"
#import "SOLSettingsManager.h"


#pragma mark - Constants

static NSString * const flickrGroupID = @"1463451@N25";


#pragma mark - SOLWeatherViewController Class Extension

@interface SOLWeatherViewController ()

@property (nonatomic) SOLWeatherView    *weatherView;

@property (nonatomic) UIImageView       *backgroundImageView;

@end


#pragma mark - SOLWeatherViewController Implementation

@implementation SOLWeatherViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[SOLSettingsManager sharedManager]addObserver:self forKeyPath:@"celsius" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backgroundImageView];
    
    self.weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.weatherView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [SOLSettingsManager sharedManager]) {
        if ([keyPath isEqualToString:@"celsius"]) {
            [self updateWeatherView];
        }
    }
}

- (void)update
{
    // check time
    
    [self.weatherView.activityIndicator startAnimating];
    
    if (self.placemark) {
        
        CZWeatherRequest *currentConditionRequest = [CZWeatherRequest requestWithType:CZCurrentConditionsRequestType];
        currentConditionRequest.location   = [CZWeatherLocation locationWithCLLocationCoordinate2D:self.placemark.location.coordinate];
        currentConditionRequest.service    = [CZWundergroundService serviceWithKey:[SOLKeyManager keyForDictionaryKey:@"wunderground"]];
        
        CZWeatherRequest *forecastConditionsRequest = [CZWeatherRequest requestWithType:CZForecastRequestType];
        forecastConditionsRequest.location  = [CZWeatherLocation locationWithCLLocationCoordinate2D:self.placemark.location.coordinate];
        forecastConditionsRequest.service   = [CZWundergroundService serviceWithKey:[SOLKeyManager keyForDictionaryKey:@"wunderground"]];
        
        [currentConditionRequest performRequestWithHandler: ^ (id data, NSError *error) {
            if (data) {
                __block CZWeatherCondition *currentCondition = (CZWeatherCondition *)data;
                
                [forecastConditionsRequest performRequestWithHandler:^(id data, NSError *error) {
                    if (data) {
                        NSArray *forecastConditions = (NSArray *)data;
                        self.currentCondition   = currentCondition;
                        self.forecastConditions = forecastConditions;
                        
                        [self updateWeatherView];
                    } else {
                        [self updateDidFail];
                    }
                    [self.weatherView.activityIndicator stopAnimating];
                }];
            } else {
                [self updateDidFail];
                [self.weatherView.activityIndicator stopAnimating];
            }
        }];
        
        [self updateBackgroundImageWithLocation:self.placemark];
    }
}

- (void)updateBackgroundImageWithLocation:(CLPlacemark *)placemark
{
    NSString *latitudeString = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
    NSString *longitudeString = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
    
    [[FlickrKit sharedFlickrKit]call:@"flickr.photos.search" args:@{@"group_id": flickrGroupID, @"accuracy":@"11", @"lat": latitudeString, @"lon":longitudeString} maxCacheAge:FKDUMaxAgeOneDay completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            NSMutableArray *photoURLs = [NSMutableArray array];
            for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
                NSURL *url = [[FlickrKit sharedFlickrKit]photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoData];
                [photoURLs addObject:url];
            }
            
            if ([photoURLs count] > 0) {
                NSURL *photoURL = photoURLs[arc4random() % [photoURLs count]];
                
                __weak __block UIImageView *weakBackgroundImageView = self.backgroundImageView;
                [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:photoURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    weakBackgroundImageView.image = [image applyBlurWithRadius:0.1
                                                                     tintColor:[UIColor colorWithWhite:0.1 alpha:0.8]
                                                         saturationDeltaFactor:1.8
                                                                     maskImage:nil];
                } failure:nil];
            }
        }
    }];
}

- (void)updateWeatherView
{
    if (self.placemark && self.currentCondition && self.forecastConditions) {
        SOLWeatherViewModel *weatherViewModel = [SOLWeatherViewModel weatherViewModelForPlacemark:self.placemark
                                                                         currentWeatherCondition:self.currentCondition
                                                                       forecastWeatherConditions:self.forecastConditions
                                                                                         celsius:[SOLSettingsManager sharedManager].isCelsius];
        self.weatherView.locationLabel.text             = weatherViewModel.locationLabelString;
        self.weatherView.conditionIconLabel.text        = weatherViewModel.conditionIconString;
        self.weatherView.conditionDescriptionLabel.text = weatherViewModel.conditionLabelString;
        self.weatherView.highLowTemperatureLabel.text   = weatherViewModel.highLowTemperatureLabelString;
        self.weatherView.currentTemperatureLabel.text   = weatherViewModel.currentTemperatureLabelString;
        self.weatherView.forecastDayOneLabel.text       = weatherViewModel.forecastDayOneLabelString;
        self.weatherView.forecastDayTwoLabel.text       = weatherViewModel.forecastDayTwoLabelString;
        self.weatherView.forecastDayThreeLabel.text     = weatherViewModel.forecastDayThreeLabelString;
        self.weatherView.forecastIconOneLabel.text      = weatherViewModel.forecastIconOneLabelString;
        self.weatherView.forecastIconTwoLabel.text      = weatherViewModel.forecastIconTwoLabelString;
        self.weatherView.forecastIconThreeLabel.text    = weatherViewModel.forecastIconThreeLabelString;
    }
}

- (void)updateDidFail
{
    
}

- (void)dealloc
{
    [[SOLSettingsManager sharedManager]removeObserver:self forKeyPath:@"celsius"];
}

@end
