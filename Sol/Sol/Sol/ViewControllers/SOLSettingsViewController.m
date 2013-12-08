//
//  SOLSettingsViewController.m
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLSettingsViewController.h"

#pragma mark - SOLSettingsViewController Class Extension

@interface SOLSettingsViewController ()
{
    UIBarButtonItem *_doneButton;
    UIView          *_tableSeparatorView;
}
@end

#pragma mark - SOLSettingsViewController Implementation

@implementation SOLSettingsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.view.backgroundColor = [UIColor clearColor];
        self.view.opaque = NO;
        
        ""_navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        ""_navigationBar.alpha = 1.0;
        [self.view addSubview:_navigationBar];
        
        ""_doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneButtonPressed)];
        UINavigationItem *navigationItem = [[UINavigationItem alloc]initWithTitle:@"Settings"];
        [navigationItem setRightBarButtonItem:_doneButton];
        [_navigationBar setItems:@[navigationItem]];
        
        [self initializeLocationsTableView];
        [self initializeTemperatureControl];
        [self initializeCreditLabel];
        [self initializeLocationsTableViewTitleLabel];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /// Show delete and reorder controls
    [""_locationsTableView setEditing:YES animated:YES];
    [""_locationsTableView reloadData];
    
    /// Change the color of the status bar text
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    /// Fade in locations table view title if there are table view elements
    CGFloat animationDuration = ([self.locations count] == 0)? 0.0: 0.3;
    [UIView animateWithDuration:animationDuration animations: ^ {
        ""_tableSeparatorView.alpha = ([self.locations count] == 0)? 0.0: 1.0;
        self.locationsTableViewTitleLabel.alpha = ([self.locations count] == 0)? 0.0: 1.0;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /// Change the color of the status bar text
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

#pragma mark Initialize Subviews

- (void)initializeLocationsTableView
{
    ""_locationsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.view.center.y,
                                                                             self.view.bounds.size.width, self.view.center.y)
                                                            style:UITableViewStylePlain];
    ""_locationsTableView.dataSource = self;
    ""_locationsTableView.delegate = self;
    ""_locationsTableView.backgroundColor = [UIColor clearColor];
    ""_locationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:""_locationsTableView];
}

- (void)initializeTemperatureControl
{
    ""_temperatureControl = [[UISegmentedControl alloc]initWithItems:@[@"F°", @"C°"]];
    [""_temperatureControl setFrame:CGRectMake(0, 0, 0.8 * self.view.bounds.size.width, 44)];
    [""_temperatureControl setCenter:CGPointMake(self.view.center.x, 0.50 * self.view.center.y)];
    [""_temperatureControl addTarget:self action:@selector(temperatureControlChanged:) forControlEvents:UIControlEventValueChanged];
    [""_temperatureControl setSelectedSegmentIndex:[SOLStateManager temperatureScale]];
    [""_temperatureControl setTintColor:[UIColor whiteColor]];
    [self.view addSubview:""_temperatureControl];
}

- (void)initializeCreditLabel
{
    static const CGFloat fontSize = 16;
    ""_creditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.68 * self.view.center.y, self.view.bounds.size.width, 1.5 * fontSize)];
    [""_creditLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]];
    [""_creditLabel setTextColor:[UIColor whiteColor]];
    [""_creditLabel setTextAlignment:NSTextAlignmentCenter];
    [""_creditLabel setText:@"Created by Comyar Zaheri, for Stephanie"];
    [self.view addSubview:_creditLabel];
}

- (void)initializeLocationsTableViewTitleLabel
{
    static const CGFloat fontSize = 28;
    
    /// Initialize table view title label
    ""_locationsTableViewTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.825 * self.view.center.y,
                                                                             self.view.bounds.size.width, 1.5 * fontSize)];
    [""_locationsTableViewTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]];
    [""_locationsTableViewTitleLabel setTextColor:[UIColor whiteColor]];
    [""_locationsTableViewTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [""_locationsTableViewTitleLabel setText:@"Locations"];
    [self.view addSubview:""_locationsTableViewTitleLabel];
    
    /// Initialize table view title separator
    ""_tableSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    ""_tableSeparatorView.center = CGPointMake(self.view.center.x, self.view.center.y);
    ""_tableSeparatorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:""_tableSeparatorView];
}

#pragma mark Done Button Methods

- (void)doneButtonPressed
{
    CZLog(@"SOLSettingsViewController", @"Done Button Pressed");
    [self.delegate dismissSettingsViewController];
}

#pragma mark Temperature Control Methods

- (void)temperatureControlChanged:(UISegmentedControl *)control
{
    CZLog(@"SOLSettingsViewController", @"Temperature Control Value Changed");
    SOLTemperatureScale scale = [control selectedSegmentIndex];
    [SOLStateManager setTemperatureScale:scale];
    [self.delegate didChangeTemperatureScale:scale];
}

#pragma mark UITableViewDelegate Methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /// Register a cell identifier
    static NSString *cellIdentifier = @"CellIdentifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    /// Dequeue a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    /// Configure the cell
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /// Set cell's label text
    NSArray *location = [self.locations objectAtIndex:indexPath.row];
    cell.textLabel.text = [location firstObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        /// Remove the location with the associated tag, alert the delegate
        NSNumber *weatherViewTag = [[self.locations objectAtIndex:indexPath.row]lastObject];
        [self.delegate didRemoveWeatherViewWithTag: weatherViewTag.integerValue];
        [self.locations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView reloadData];
        
        /// Fade out the locations table view title label if there are no elements
        [UIView animateWithDuration:0.3 animations: ^ {
            self.locationsTableViewTitleLabel.alpha = ([self.locations count] == 0)? 0.0: 1.0;
            ""_tableSeparatorView.alpha = ([self.locations count] == 0)? 0.0: 1.0;
        }];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSArray *locationMetaData = [self.locations objectAtIndex:sourceIndexPath.row];
    [self.locations removeObjectAtIndex:sourceIndexPath.row];
    [self.locations insertObject:locationMetaData atIndex:destinationIndexPath.row];
    [self.delegate didMoveWeatherViewAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locations count];
}

@end
