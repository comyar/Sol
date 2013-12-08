//
//  SOLAppDelegate.h
//  Sol
//
//  Created by Comyar Zaheri on 7/30/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SOLMainViewController;

@interface SOLAppDelegate : UIResponder <UIApplicationDelegate>
{
    /// The initial view controller presented to the user
    SOLMainViewController   *_mainViewController;
}

/////////////////////////////////////////////////////////////////////////////
/// @name Properties
/////////////////////////////////////////////////////////////////////////////

/// App window
@property (strong, nonatomic) UIWindow *window;

@end
