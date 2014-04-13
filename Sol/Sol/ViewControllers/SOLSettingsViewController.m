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

// -----
// @name Subviews
// -----

// Displays the location metadata
@property (strong, nonatomic) UITableView           *locationsTableView;

// Navigation bar for the controller, contains the done button
@property (strong, nonatomic) UINavigationBar       *navigationBar;

// Done button inside navigation bar
@property (strong, nonatomic) UIBarButtonItem       *doneButton;

// Displays the title of the locations table view
@property (strong, nonatomic) UILabel               *locationsTableViewTitleLabel;

// Aesthetic line drawn beneath the locations table view title label
@property (strong, nonatomic) UIView                *tableSeparatorView;

// Control to change the temperature scale
@property (strong, nonatomic) UISegmentedControl    *temperatureControl;

// Displays credits for the app
@property (strong, nonatomic) UILabel               *creditLabel;

@end

#pragma mark - SOLSettingsViewController Implementation

@implementation SOLSettingsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.view.backgroundColor = [UIColor clearColor];
        self.view.opaque = NO;

        self.navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.tintColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.navigationBar.translucent = YES;
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:22]}];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0, self.navigationBar.bounds.size.height - 0.5, self.navigationBar.bounds.size.width, 0.5);
        bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self.navigationBar.layer addSublayer:bottomBorder];
        [self.view addSubview:self.navigationBar];
        
        
        self.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneButtonPressed)];
        UINavigationItem *navigationItem = [[UINavigationItem alloc]initWithTitle:@"Settings"];
        [navigationItem setRightBarButtonItem:self.doneButton];
        [self.navigationBar setItems:@[navigationItem]];
        
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
    
    // Show delete and reorder controls
    [self.locationsTableView setEditing:YES animated:YES];
    [self.locationsTableView reloadData];
    
    // Fade in locations table view title if there are table view elements
    CGFloat animationDuration = ([self.locations count] == 0)? 0.0: 0.3;
    [UIView animateWithDuration:animationDuration animations: ^ {
        self.tableSeparatorView.alpha = ([self.locations count] == 0)? 0.0: 1.0;
        self.locationsTableViewTitleLabel.alpha = ([self.locations count] == 0)? 0.0: 1.0;
    }];
}

#pragma mark Initialize Subviews

- (void)initializeLocationsTableView
{
    self.locationsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0.9 * self.view.center.y,
                                                                           CGRectGetWidth(self.view.bounds), self.view.center.y)
                                                          style:UITableViewStylePlain];
    self.locationsTableView.dataSource = self;
    self.locationsTableView.delegate = self;
    self.locationsTableView.backgroundColor = [UIColor clearColor];
    self.locationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.locationsTableView];
}

- (void)initializeTemperatureControl
{
    self.temperatureControl = [[UISegmentedControl alloc]initWithItems:@[@"F°", @"C°"]];
    [self.temperatureControl setFrame:CGRectMake(0, 0, 0.8 * CGRectGetWidth(self.view.bounds), 44)];
    [self.temperatureControl setCenter:CGPointMake(self.view.center.x, 0.50 * self.view.center.y)];
    [self.temperatureControl addTarget:self action:@selector(temperatureControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.temperatureControl setSelectedSegmentIndex:[SOLStateManager temperatureScale]];
    [self.temperatureControl setTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.temperatureControl];
}

- (void)initializeCreditLabel
{
    static const CGFloat fontSize = 14;
    self.creditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 2.0 * fontSize,
                                                                self.view.bounds.size.width, 1.5 * fontSize)];
    [self.creditLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]];
    [self.creditLabel setTextColor:[UIColor whiteColor]];
    [self.creditLabel setTextAlignment:NSTextAlignmentCenter];
    [self.creditLabel setText:@"Created by Comyar Zaheri"];
    [self.view addSubview:self.creditLabel];
}

- (void)initializeLocationsTableViewTitleLabel
{
    static const CGFloat fontSize = 20;
    
    // Initialize table view title label
    self.locationsTableViewTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.775 * self.view.center.y,
                                                                                 CGRectGetWidth(self.view.bounds), 1.5 * fontSize)];
    [self.locationsTableViewTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize]];
    [self.locationsTableViewTitleLabel setTextColor:[UIColor whiteColor]];
    [self.locationsTableViewTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.locationsTableViewTitleLabel setText:@"Locations"];
    [self.view addSubview:self.locationsTableViewTitleLabel];
    
    // Initialize table view title separator
    self.tableSeparatorView = [[UIView alloc]initWithFrame:CGRectMake(16, 0, CGRectGetWidth(self.view.bounds) - 32, 0.5)];
    self.tableSeparatorView.center = CGPointMake(self.view.center.x, 0.9 * self.view.center.y);
    self.tableSeparatorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [self.view addSubview:self.tableSeparatorView];
}

#pragma mark Done Button Methods

- (void)doneButtonPressed
{
    [self.delegate dismissSettingsViewController];
}

#pragma mark Temperature Control Methods

- (void)temperatureControlChanged:(UISegmentedControl *)control
{
    SOLTemperatureScale scale = (SOLTemperatureScale)[control selectedSegmentIndex];
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
    static NSString *cellIdentifier = @"CellIdentifier";
    
    // Dequeue a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        // Initialize new cell if cell is null
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Set cell's label text
    NSArray *location = [self.locations objectAtIndex:indexPath.row];
    cell.textLabel.text = [location firstObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Remove the location with the associated tag, alert the delegate
        NSNumber *weatherViewTag = [[self.locations objectAtIndex:indexPath.row]lastObject];
        [self.delegate didRemoveWeatherViewWithTag: weatherViewTag.integerValue];
        [self.locations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData];
        
        // Fade out the locations table view title label if there are no elements
        [UIView animateWithDuration:0.3 animations: ^ {
            self.locationsTableViewTitleLabel.alpha = ([self.locations count] == 0)? 0.0: 1.0;
            self.tableSeparatorView.alpha = ([self.locations count] == 0)? 0.0: 1.0;
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
