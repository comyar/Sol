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

- (void)addSubview:(UIView *)weatherView isLaunch:(BOOL)launch
{
    [super addSubview:weatherView];
    
    NSUInteger numSubviews = [self.subviews count];
    [weatherView setFrame:CGRectMake(CGRectGetWidth(self.bounds) * (numSubviews - 1), 0,
                                     CGRectGetWidth(weatherView.bounds), CGRectGetHeight(weatherView.bounds))];
    [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds) * numSubviews, self.contentSize.height)];
    
    if (!launch) {
        [self setContentOffset:CGPointMake(weatherView.bounds.size.width * (self.subviews.count - 1), 0) animated:YES];
    }
}

- (void)insertSubview:(UIView *)weatherView atIndex:(NSInteger)index
{
    [super insertSubview:weatherView atIndex:index];
    
    [weatherView setFrame:CGRectMake(CGRectGetWidth(self.bounds) * index, 0,
                                     CGRectGetWidth(weatherView.bounds), CGRectGetHeight(weatherView.bounds))];
    NSUInteger numSubviews = [self.subviews count];
    for(NSUInteger i = index + 1; i < numSubviews; ++i) {
        UIView *subview = [self.subviews objectAtIndex:i];
        [subview setFrame:CGRectMake(CGRectGetWidth(self.bounds) * i, 0,
                                     CGRectGetWidth(weatherView.bounds), CGRectGetHeight(weatherView.bounds))];
    }
    [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds) * numSubviews, self.contentSize.height)];
}

- (void)removeSubview:(UIView *)subview
{
    NSUInteger index = [self.subviews indexOfObject:subview];
    if(index != NSNotFound) {
        NSUInteger numSubviews = [self.subviews count];
        for(NSInteger i = index + 1; i < numSubviews; ++i) {
            UIView *view = [self.subviews objectAtIndex:i];
            [view setFrame:CGRectOffset(view.frame, -1.0 * CGRectGetWidth(subview.bounds), 0)];
        }
        [subview removeFromSuperview];
        [self setContentSize:CGSizeMake(CGRectGetWidth(self.bounds) * (numSubviews - 1), self.contentSize.height)];
    }
}

@end
