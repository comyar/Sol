//
//  SOLPagingScrollView.h
//  Sol
//
//  Created by Comyar Zaheri on 7/30/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

/**
 SOLPagingScrollView manages and displays all SOLWeatherViews as individual pages in a scroll view. All subviews of
 a SOLPagingScrollView are treated as pages.
 */
@interface SOLPagingScrollView : UIScrollView

// -----
// @name Configuring a Paging Scroll View
// -----

/**
 Adds a weatherView as page in the paging scroll view
 @param weatherView View to add
 */
- (void)addSubview:(UIView *)weatherView isLaunch:(BOOL)launch;

/**
 Inserts a weatherView as a page at the given index
 @param weatherView View to add
 @param index Index to add the view
 */
- (void)insertSubview:(UIView *)weatherView atIndex:(NSInteger)index;

/**
 Removes the given weatherView from the paging scroll view
 @param weatherView View to remove
 */
- (void)removeSubview:(UIView *)weatherView;

@end
