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


#pragma mark - SOLWeatherViewController Class Extension

@interface SOLWeatherViewController ()

@property (nonatomic) SOLWeatherView *weatherView;

@end


#pragma mark - SOLWeatherViewController Implementation

@implementation SOLWeatherViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weatherView = [[SOLWeatherView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.weatherView];
}

- (void)update
{
    if (self.citymark) {
        
        CZWeatherRequest *currentConditionRequest = [CZWeatherRequest requestWithType:CZCurrentConditionsRequestType];
        currentConditionRequest.location   = [CZWeatherLocation locationWithCLLocationCoordinate2D:self.citymark.coordinate];
        currentConditionRequest.service    = [CZForecastioService serviceWithKey:[SOLKeyManager keyForDictionaryKey:@"forecast.io"]];
        
        CZWeatherRequest *forecastConditionsRequest = [CZWeatherRequest requestWithType:CZForecastRequestType];
        forecastConditionsRequest.location  = [CZWeatherLocation locationWithCLLocationCoordinate2D:self.citymark.coordinate];
        forecastConditionsRequest.service   = [CZForecastioService serviceWithKey:[SOLKeyManager keyForDictionaryKey:@"forecast.io"]];
        
        [currentConditionRequest performRequestWithHandler: ^ (id data, NSError *error) {
            if (data) {
                __block CZWeatherCondition *currentCondition = (CZWeatherCondition *)data;
                
                [forecastConditionsRequest performRequestWithHandler:^(id data, NSError *error) {
                    if (data) {
                        NSArray *forecastConditions = (NSArray *)data;
                        self.currentCondition   = currentCondition;
                        self.forecastConditions = forecastConditions;
                    } else {
                        [self updateDidFail];
                    }
                }];
            } else {
                [self updateDidFail];
            }
        }];
    }
}

- (void)updateWeatherView
{
    if (self.citymark && self.currentCondition && self.forecastConditions) {
        SOLWeatherViewModel *weatherViewModel = [SOLWeatherViewModel weatherViewModelForCitymark:self.citymark
                                                                         currentWeatherCondition:self.currentCondition
                                                                       forecastWeatherConditions:self.forecastConditions
                                                                                         celsius:NO];
    }
}

- (void)updateDidFail
{
    
}

@end
