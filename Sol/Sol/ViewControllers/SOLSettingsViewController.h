//
//  SOLSettingsViewController.h
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
