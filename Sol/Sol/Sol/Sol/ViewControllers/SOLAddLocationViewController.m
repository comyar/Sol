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
{
    CLGeocoder      *_geocoder;
    NSMutableArray  *_searchResults;
    UINavigationBar *_navigationBar;
    UIBarButtonItem *_doneButton;
}
@end


#pragma mark - SOLAddLocationViewController Implementation

@implementation SOLAddLocationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.view.backgroundColor = [UIColor clearColor];
        self.view.opaque = NO;
        
        self->_geocoder = [[CLGeocoder alloc]init];
        self->_searchResults = [[NSMutableArray alloc]initWithCapacity:5];
        
        self->_navigationBar =[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        [self.view addSubview:self->_navigationBar];
        
        self->_doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneButtonPressed)];
        self->_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        self->_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self->_searchBar.placeholder = @"Name of City";
        self->_searchBar.delegate = self;
        
        self->_searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
        self->_searchController.delegate = self;
        self->_searchController.searchResultsDelegate = self;
        self->_searchController.searchResultsDataSource = self;
        self->_searchController.searchResultsTitle = @"Add Location";
        self->_searchController.displaysSearchBarInNavigationBar = YES;
        self->_searchController.navigationItem.rightBarButtonItems = @[_doneButton];
        self->_navigationBar.items = @[_searchController.navigationItem];
    }
    return self;
}

#pragma mark UIViewController Methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self->_searchController setActive:YES animated:NO];
    [self->_searchController.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self->_searchController setActive:NO animated:NO];
    [self->_searchController.searchBar resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate dismissAddLocationViewController];
}

#pragma mark DoneButton Methods

- (void)doneButtonPressed
{
    CZLog(@"SOLAddLocationViewController", @"Done Button Pressed");
    [self.delegate dismissAddLocationViewController];
}

#pragma mark UISearchDisplayControllerDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self->_geocoder geocodeAddressString:searchString completionHandler: ^ (NSArray *placemarks, NSError *error) {
        self->_searchResults = [[NSMutableArray alloc]initWithCapacity:1];
        for(CLPlacemark *placemark in placemarks) {
            if(placemark.locality) {
                [self->_searchResults addObject:placemark];
            }
        }
        [controller.searchResultsTableView reloadData];
    }];
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setFrame:CGRectMake(0, self->_navigationBar.bounds.size.height, self.view.bounds.size.width,
                                   self.view.bounds.size.height - self->_navigationBar.bounds.size.height)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    [self.view bringSubviewToFront:self->_navigationBar];
}

#pragma mark UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(tableView == self->_searchController.searchResultsTableView) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        CLPlacemark *placemark = [self->_searchResults objectAtIndex:indexPath.row];
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
    if(tableView == self->_searchController.searchResultsTableView) {
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        CLPlacemark *placemark = [self->_searchResults objectAtIndex:indexPath.row];
        [self.delegate didAddLocationWithPlacemark:placemark];
        [self.delegate dismissAddLocationViewController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self->_searchResults count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self->_navigationBar.frame = CGRectMake(self.view.bounds.origin.x,
                                      self.view.bounds.origin.y,
                                      self->_navigationBar.frame.size.width,
                                      self->_navigationBar.frame.size.height);
}

@end
