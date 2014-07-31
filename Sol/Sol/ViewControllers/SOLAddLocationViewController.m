//
//  SOLAddLocationViewController.m
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

#import "SOLAddLocationViewController.h"


#pragma mark - SOLAddLocationViewController Class Extension

@interface SOLAddLocationViewController () <UISearchDisplayDelegate, UITableViewDelegate,
                                            UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>

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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark DoneButton Methods

- (void)doneButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UISearchDisplayControllerDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

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
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
