//
//  SOLSettingsViewController.h
//  Copyright (c) 2014 Comyar Zaheri, http://comyar.io
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#pragma mark - Imports

@import UIKit;


#pragma mark - SOLSettingsViewControllerDelegate Protocol

/**
 */
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
//- (void)didChangeTemperatureScale:(SOLTemperatureScale)scale;

/**
 Called by a SOLSettingsViewController when the controller needs to be dismissed
 */
- (void)dismissSettingsViewController;

@end


#pragma mark - SOLSettingsViewController Interface

/**
 */
@interface SOLSettingsViewController : UIViewController 

// -----
// @name Properties
// -----

// List of location metadata to display in the locations table view
@property (strong, nonatomic)           NSMutableArray      *locations;

// Object that implements the SOLSettingsViewController Delegate Protocol
@property (weak, nonatomic) id<SOLSettingsViewControllerDelegate> delegate;

@end
