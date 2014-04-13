//
//  SOLWundergroundDownloader.m
//  Sol
//
//  Created by Comyar Zaheri on 8/7/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLWundergroundDownloader.h"
#import "SOLWeatherData.h"
#import "NSString+Substring.h"
#import "Climacons.h"

#pragma mark - SOLWundergroundDownloader Class Extension

@interface SOLWundergroundDownloader ()

//  Used by the downloader to determine the names of locations based on coordinates
@property (nonatomic) CLGeocoder    *geocoder;

//  API key
@property (nonatomic) NSString      *key;

@end

#pragma mark - SOLWundergroundDownloader Implementation

@implementation SOLWundergroundDownloader

- (instancetype)init
{
    //  Instances of SOLWundergroundDownloader should be impossible to make using init
    [NSException raise:@"SOLSingletonException" format:@"SOLWundergroundDownloader cannot be initialized using init"];
    return nil;
}

#pragma mark Initializing a SOLWundergroundDownloader

+ (SOLWundergroundDownloader *)sharedDownloader
{
    static SOLWundergroundDownloader *sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#warning Project bundle must contain a file name "API_KEY" containing a valid Wunderground API key
        NSString *path = [[NSBundle mainBundle]pathForResource:@"API_KEY" ofType:@""];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *apiKey = [content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        sharedDownloader = [[SOLWundergroundDownloader alloc]initWithAPIKey:apiKey];
    });
    return sharedDownloader;
}

- (instancetype)initWithAPIKey:(NSString *)key
{
    if(self = [super init]) {
        self.key = key;
        self.geocoder = [[CLGeocoder alloc]init];
    }
    return self;
}

#pragma mark Using a SOLWundergroundDownloader

- (void)dataForLocation:(CLLocation *)location placemark:(CLPlacemark *)placemark withTag:(NSInteger)tag completion:(SOLWeatherDataDownloadCompletion)completion
{
    //  Requests are not made if the (location and completion) or the delegate is nil
    if(!location || !completion) {
        return;
    }
    
    //  Turn on the network activity indicator in the status bar
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    
    //  Get the url request
    NSURLRequest *request = [self urlRequestForLocation:location];
    
    //  Make an asynchronous request to the url
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^ (NSURLResponse * response, NSData *data, NSError *connectionError) {
         
         //  Report connection errors as download failures to the delegate
         if(connectionError) {
             completion(nil, connectionError);
         } else {
             
             //  Serialize the downloaded JSON document and return the weather data to the delegate
             @try {
                 NSDictionary *JSON = [self serializedData:data];
                 SOLWeatherData *weatherData = [self dataFromJSON:JSON];
                 if(placemark) {
                     weatherData.placemark = placemark;
                     completion(weatherData, connectionError);
                 } else {
                     //  Reverse geocode the given location in order to get city, state, and country
                     [self.geocoder reverseGeocodeLocation:location completionHandler: ^ (NSArray *placemarks, NSError *error) {
                         if(placemarks) {
                             weatherData.placemark = [placemarks lastObject];
                             completion(weatherData, error);
                         } else if(error) {
                             completion(nil, error);
                         }
                     }];
                 }
             }
             
             //  Report any failures during serialization as download failures to the delegate
             @catch (NSException *exception) {
                 completion(nil, [NSError errorWithDomain:@"SOLWundergroundDownloader Internal State Error" code:-1 userInfo:nil]);
             }
             
             //  Always turn off the network activity indicator after requests are fulfilled
             @finally {
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }
         }
     }];
}

- (void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSInteger)tag completion:(SOLWeatherDataDownloadCompletion)completion
{
    [self dataForLocation:placemark.location placemark:placemark withTag:tag completion:completion];
}

- (void)dataForLocation:(CLLocation *)location withTag:(NSInteger)tag completion:(SOLWeatherDataDownloadCompletion)completion
{
    [self dataForLocation:location placemark:nil withTag:tag completion:completion];
}

- (NSURLRequest *)urlRequestForLocation:(CLLocation *)location
{
    static NSString *baseURL =  @"http://api.wunderground.com/api/";
    static NSString *parameters = @"/forecast/conditions/q/";
    CLLocationCoordinate2D coordinates = location.coordinate;
    NSString *requestURL = [NSString stringWithFormat:@"%@%@%@%f,%f.json", baseURL, self.key, parameters,
                            coordinates.latitude, coordinates.longitude];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
}

- (NSDictionary *)serializedData:(NSData *)data
{
    NSError *JSONSerializationError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONSerializationError];
    if(JSONSerializationError) {
        [NSException raise:@"JSON Serialization Error" format:@"Failed to parse weather data"];
    }
    return JSON;
}

- (SOLWeatherData *)dataFromJSON:(NSDictionary *)JSON
{
    NSArray *currentObservation                 = [JSON             objectForKey:@"current_observation"];
    NSArray *forecast                           = [JSON             objectForKey:@"forecast"];
    NSArray *simpleforecast                     = [forecast         valueForKey:@"simpleforecast"];
    NSArray *forecastday                        = [simpleforecast   valueForKey:@"forecastday"];
    NSArray *forecastday0                       = [forecastday      objectAtIndex:0];
    NSArray *forecastday1                       = [forecastday      objectAtIndex:1];
    NSArray *forecastday2                       = [forecastday      objectAtIndex:2];
    NSArray *forecastday3                       = [forecastday      objectAtIndex:3];
    
    SOLWeatherData *data = [[SOLWeatherData alloc]init];
    
    CGFloat currentHighTemperatureF             = [[[forecastday0 valueForKey:@"high"]  valueForKey:@"fahrenheit"]doubleValue];
    CGFloat currentHighTemperatureC             = [[[forecastday0 valueForKey:@"high"]  valueForKey:@"celsius"]doubleValue];
    CGFloat currentLowTemperatureF              = [[[forecastday0 valueForKey:@"low"]   valueForKey:@"fahrenheit"]doubleValue];
    CGFloat currentLowTemperatureC              = [[[forecastday0 valueForKey:@"low"]   valueForKey:@"celsius"]doubleValue];
    CGFloat currentTemperatureF                 = [[currentObservation valueForKey:@"temp_f"] doubleValue];
    CGFloat currentTemperatureC                 = [[currentObservation valueForKey:@"temp_c"] doubleValue];
    
    data.currentSnapshot.dayOfWeek              = [[forecastday0 valueForKey:@"date"] valueForKey:@"weekday"];
    data.currentSnapshot.conditionDescription   = [currentObservation valueForKey:@"weather"];
    data.currentSnapshot.icon                   = [self iconForCondition:data.currentSnapshot.conditionDescription];
    data.currentSnapshot.highTemperature        = SOLTemperatureMake(currentHighTemperatureF,   currentHighTemperatureC);
    data.currentSnapshot.lowTemperature         = SOLTemperatureMake(currentLowTemperatureF,    currentLowTemperatureC);
    data.currentSnapshot.currentTemperature     = SOLTemperatureMake(currentTemperatureF,       currentTemperatureC);
    
    SOLWeatherSnapshot *forecastOne             = [[SOLWeatherSnapshot alloc]init];
    forecastOne.conditionDescription            = [forecastday1 valueForKey:@"conditions"];
    forecastOne.icon                            = [self iconForCondition:forecastOne.conditionDescription];
    forecastOne.dayOfWeek                       = [[forecastday1 valueForKey:@"date"] valueForKey:@"weekday"];
    [data.forecastSnapshots addObject:forecastOne];
    
    SOLWeatherSnapshot *forecastTwo             = [[SOLWeatherSnapshot alloc]init];
    forecastTwo.conditionDescription            = [forecastday2 valueForKey:@"conditions"];
    forecastTwo.icon                            = [self iconForCondition:forecastTwo.conditionDescription];
    forecastTwo.dayOfWeek                       = [[forecastday2 valueForKey:@"date"] valueForKey:@"weekday"];
    [data.forecastSnapshots addObject:forecastTwo];
    
    SOLWeatherSnapshot *forecastThree           = [[SOLWeatherSnapshot alloc]init];
    forecastThree.conditionDescription          = [forecastday3 valueForKey:@"conditions"];
    forecastThree.icon                          = [self iconForCondition:forecastThree.conditionDescription];
    forecastThree.dayOfWeek                     = [[forecastday3 valueForKey:@"date"] valueForKey:@"weekday"];
    [data.forecastSnapshots addObject:forecastThree];
    
    data.timestamp = [NSDate date];
    
    return data;
}

- (NSString *)iconForCondition:(NSString *)condition
{
    NSString *iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    NSString *lowercaseCondition = [condition lowercaseString];
    
    if([lowercaseCondition contains:@"clear"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    } else if([lowercaseCondition contains:@"cloud"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloud];
    } else if([lowercaseCondition contains:@"drizzle"]  ||
              [lowercaseCondition contains:@"rain"]     ||
              [lowercaseCondition contains:@"thunderstorm"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconRain];
    } else if([lowercaseCondition contains:@"snow"]     ||
              [lowercaseCondition contains:@"hail"]     ||
              [lowercaseCondition contains:@"ice"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSnow];
    } else if([lowercaseCondition contains:@"fog"]      ||
              [lowercaseCondition contains:@"overcast"] ||
              [lowercaseCondition contains:@"smoke"]    ||
              [lowercaseCondition contains:@"dust"]     ||
              [lowercaseCondition contains:@"ash"]      ||
              [lowercaseCondition contains:@"mist"]     ||
              [lowercaseCondition contains:@"haze"]     ||
              [lowercaseCondition contains:@"spray"]    ||
              [lowercaseCondition contains:@"squall"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconHaze];
    }
    return iconName;
}

@end
