//
//  SOLPagingScrollView.m
//  Sol
//
//  Created by Comyar Zaheri on 7/30/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "SOLPagingScrollView.h"

#pragma mark - SOLPagingScrollView Implementation

@implementation SOLPagingScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
    }
    return self;
}

#pragma mark Configuring a Paging Scroll View

- (void)addSubview:(UIView *)weatherView
{
    [super addSubview:weatherView];
    [weatherView setFrame:CGRectMake(self.bounds.size.width * (self.subviews.count - 1), 0,
                                     weatherView.bounds.size.width, weatherView.bounds.size.height)];
    [self setContentSize:CGSizeMake(self.bounds.size.width * self.subviews.count, self.contentSize.height)];
    CZLog(@"SOLPagingScrollView", @"Added subview");
}

- (void)insertSubview:(UIView *)weatherView atIndex:(NSInteger)index
{
    [super insertSubview:weatherView atIndex:index];
    [weatherView setFrame:CGRectMake(self.bounds.size.width * index, 0, weatherView.bounds.size.width, weatherView.bounds.size.height)];
    for(int i = index + 1; i < self.subviews.count; ++i) {
        UIView *subview = [self.subviews objectAtIndex:i];
        [subview setFrame:CGRectMake(self.bounds.size.width * i, 0, weatherView.bounds.size.width, weatherView.bounds.size.height)];
    }
    [self setContentSize:CGSizeMake(self.bounds.size.width * self.subviews.count, self.contentSize.height)];
    CZLog(@"SOLPagingScrollView", @"Inserted subview at index: %d", index);
}

- (void)removeSubview:(UIView *)subview
{
    int index = [self.subviews indexOfObject:subview];
    if(index != NSNotFound) {
        NSInteger count = [self.subviews count];
        for(int i = index + 1; i < count; ++i) {
            UIView *view = [self.subviews objectAtIndex:i];
            [view setFrame:CGRectOffset(view.frame, -subview.bounds.size.width, 0)];
        }
        [subview removeFromSuperview];
        [self setContentSize:CGSizeMake(self.bounds.size.width * self.subviews.count, self.contentSize.height)];
        CZLog(@"SOLPagingScrollView", @"Removed subview");
    } else {
        CZLog(@"SOLPagingScrollView", @"Failed to find the given subview to remove");
    }
}

@end
