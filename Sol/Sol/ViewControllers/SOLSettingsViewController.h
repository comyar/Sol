//
//  SOLSettingsViewController.h
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOLStateManager.h"

@protocol SOLSettingsViewControllerDelegate <NSObject>

/**
 Called by a SOLSettingsViewController when a weather view is moved by the user
 @param sourceIndex         Current index of the weather view to move
 @param destinationIndex    Index to move the weather view to
 */
- (void)didMoveWeatherViewAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

/**
 Called by a SOLSettingsViewController when a weather view is removed by the user
 @param tag Tag of the weather view to remove
 */
- (void)didRemoveWeatherViewWithTag:(NSInteger)tag;

/**
 Called by a SOLSettingsViewController when the user changes the temperature scale
 @param scale New temperature scale set by the user
 */
- (void)didChangeTemperatureScale:(SOLTemperatureScale)scale;

/**
 Called by a SOLSettingsViewController when the controller needs to be dismissed
 */
- (void)dismissSettingsViewController;

@end

@interface SOLSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

// -----
// @name Properties
// -----

// List of location metadata to display in the locations table view
@property (strong, nonatomic)           NSMutableArray      *locations;

// Object that implements the SOLSettingsViewController Delegate Protocol
@property (weak, nonatomic) id<SOLSettingsViewControllerDelegate> delegate;

@end
