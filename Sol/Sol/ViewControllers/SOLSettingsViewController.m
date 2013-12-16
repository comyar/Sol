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
        
        self->_navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        [self->_navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self->_navigationBar.shadowImage = [UIImage new];
        self->_navigationBar.tintColor = [UIColor colorWithWhite:1 alpha:0.7];
        self->_navigationBar.translucent = YES;
        [self->_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self->_navigationBar.bounds.size.height-0.5, self->_navigationBar.bounds.size.width, 0.5f);
        bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self->_navigationBar.layer addSublayer:bottomBorder];
        
        [self.view addSubview:_navigationBar];
        
        self->_doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
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
    [self->_locationsTableView setEditing:YES animated:YES];
    [self->_locationsTableView reloadData];
    
    /// Fade in locations table view title if there are table view elements
    CGFloat animationDuration = ([self.locations count] == 0)? 0.0: 0.3;
    [UIView animateWithDuration:animationDuration animations: ^ {
        self->_tableSeparatorView.alpha = ([self.locations count] == 0)? 0.0: 1.0;
        self.locationsTableViewTitleLabel.alpha = ([self.locations count] == 0)? 0.0: 1.0;
    }];
}

#pragma mark Initialize Subviews

- (void)initializeLocationsTableView
{
    self->_locationsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.view.center.y,
                                                                             self.view.bounds.size.width, self.view.center.y)
                                                            style:UITableViewStylePlain];
    self->_locationsTableView.dataSource = self;
    self->_locationsTableView.delegate = self;
    self->_locationsTableView.backgroundColor = [UIColor clearColor];
    self->_locationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self->_locationsTableView];
}

- (void)initializeTemperatureControl
{
    self->_temperatureControl = [[UISegmentedControl alloc]initWithItems:@[@"F°", @"C°"]];
    [self->_temperatureControl setFrame:CGRectMake(0, 0, 0.8 * self.view.bounds.size.width, 44)];
    [self->_temperatureControl setCenter:CGPointMake(self.view.center.x, 0.50 * self.view.center.y)];
    [self->_temperatureControl addTarget:self action:@selector(temperatureControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self->_temperatureControl setSelectedSegmentIndex:[SOLStateManager temperatureScale]];
    [self->_temperatureControl setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self->_temperatureControl];
}

- (void)initializeCreditLabel
{
    static const CGFloat fontSize = 16;
    self->_creditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.68 * self.view.center.y, self.view.bounds.size.width, 1.5 * fontSize)];
    [self->_creditLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]];
    [self->_creditLabel setTextColor:[UIColor whiteColor]];
    [self->_creditLabel setTextAlignment:NSTextAlignmentCenter];
    [self->_creditLabel setText:@"Created by Comyar Zaheri, for Stephanie"];
    [self.view addSubview:_creditLabel];
}

- (void)initializeLocationsTableViewTitleLabel
{
    static const CGFloat fontSize = 28;
    
    /// Initialize table view title label
    self->_locationsTableViewTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.825 * self.view.center.y,
                                                                             self.view.bounds.size.width, 1.5 * fontSize)];
    [self->_locationsTableViewTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]];
    [self->_locationsTableViewTitleLabel setTextColor:[UIColor whiteColor]];
    [self->_locationsTableViewTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self->_locationsTableViewTitleLabel setText:@"Locations"];
    [self.view addSubview:self->_locationsTableViewTitleLabel];
    
    /// Initialize table view title separator
    self->_tableSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    self->_tableSeparatorView.center = CGPointMake(self.view.center.x, self.view.center.y);
    self->_tableSeparatorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self->_tableSeparatorView];
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
            self->_tableSeparatorView.alpha = ([self.locations count] == 0)? 0.0: 1.0;
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
