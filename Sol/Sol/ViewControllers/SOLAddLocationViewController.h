//
//  SOLAddLocationViewController.h
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SOLAddLocationViewControllerDelegate <NSObject>

/**
 Called by a SOLAddLocationViewController when the user chooses a new location
 to add the list of weather views.
 @param placemark Placemark of the location the user added
 */
- (void)didAddLocationWithPlacemark:(CLPlacemark *)placemark;

/**
 Called by a SOLAddLocationViewController when the view controller needs to
 be dismissed.
 */
- (void)dismissAddLocationViewController;

@end

@interface SOLAddLocationViewController : UIViewController <UISearchDisplayDelegate, UITableViewDelegate,
                                                                UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>

// -----
// @name Properties
// -----

// Object implementing the SOLAddLocationViewControllerDelegate protocol
@property (weak, nonatomic) id<SOLAddLocationViewControllerDelegate> delegate;

@end
