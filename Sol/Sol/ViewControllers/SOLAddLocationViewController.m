//
//  SOLAddLocationViewController.m
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLAddLocationViewController.h"


#pragma mark - SOLAddLocationViewController Class Extension

@interface SOLAddLocationViewController ()

// Used to geocode search location
@property (strong, nonatomic) CLGeocoder                    *geocoder;

// Results of a search
@property (strong, nonatomic) NSMutableArray                *searchResults;

// Location search results display controller
@property (strong, nonatomic) UISearchDisplayController     *searchController;

// -----
// @name Subviews
// -----

// Location search bar
@property (strong, nonatomic) UISearchBar                   *searchBar;

// Navigation bar at the top of the view
@property (strong, nonatomic) UINavigationBar               *navigationBar;

// Done button inside navigation bar
@property (strong, nonatomic) UIBarButtonItem               *doneButton;

@end


#pragma mark - SOLAddLocationViewController Implementation

@implementation SOLAddLocationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.view.backgroundColor = [UIColor clearColor];
        self.view.opaque = NO;
        
        self.geocoder = [[CLGeocoder alloc]init];
        self.searchResults = [[NSMutableArray alloc]initWithCapacity:5];
        
        self.navigationBar =[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        
        [self.view addSubview:self.navigationBar];
        
        self.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneButtonPressed)];
        // Inititalize and configure search bar
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.placeholder = @"Name of City";
        self.searchBar.delegate = self;
        
        // Initialize and configure search controller
        self.searchController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
        self.searchController.delegate = self;
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchResultsDataSource = self;
        self.searchController.searchResultsTitle = @"Add Location";
        self.searchController.displaysSearchBarInNavigationBar = YES;
        self.searchController.navigationItem.rightBarButtonItems = @[self.doneButton];
        self.navigationBar.items = @[self.searchController.navigationItem];
    }
    return self;
}

#pragma mark UIViewController Methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self.searchController setActive:YES animated:NO];
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.searchController setActive:NO animated:NO];
    [self.searchController.searchBar resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate dismissAddLocationViewController];
}

#pragma mark DoneButton Methods

- (void)doneButtonPressed
{
    [self.delegate dismissAddLocationViewController];
}

#pragma mark UISearchDisplayControllerDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.geocoder geocodeAddressString:searchString completionHandler: ^ (NSArray *placemarks, NSError *error) {
        self.searchResults = [[NSMutableArray alloc]initWithCapacity:1];
        for(CLPlacemark *placemark in placemarks) {
            if(placemark.locality) {
                [self.searchResults addObject:placemark];
            }
        }
        [controller.searchResultsTableView reloadData];
    }];
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setFrame:CGRectMake(0, CGRectGetHeight(self.navigationBar.bounds), CGRectGetWidth(self.view.bounds),
                                   CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.navigationBar.bounds))];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    [self.view bringSubviewToFront:self.navigationBar];
}

#pragma mark UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    
    // Dequeue cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure cell for the search results table view
    if(tableView == self.searchController.searchResultsTableView) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        CLPlacemark *placemark = [self.searchResults objectAtIndex:indexPath.row];
        NSString *city = placemark.locality;
        NSString *country = placemark.country;
        NSString *cellText = [NSString stringWithFormat:@"%@, %@", city, country];
        if([[country lowercaseString] isEqualToString:@"united states"]) {
            NSString *state = placemark.administrativeArea;
            cellText = [NSString stringWithFormat:@"%@, %@", city, state];
        }
        cell.textLabel.text = cellText;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchController.searchResultsTableView) {
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        CLPlacemark *placemark = [self.searchResults objectAtIndex:indexPath.row];
        [self.delegate didAddLocationWithPlacemark:placemark];
        [self.delegate dismissAddLocationViewController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.navigationBar.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                          CGRectGetWidth(self.navigationBar.frame),
                                          CGRectGetHeight(self.navigationBar.frame));
}

@end
