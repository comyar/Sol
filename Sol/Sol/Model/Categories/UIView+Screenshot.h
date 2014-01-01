//
//  UIView+Screenshot.h
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIViewScreenshotAsyncCompletion) (UIImage *image);

@interface UIView (Screenshot)

- (UIImage *)screenshot;
- (void)screenshotAsyncWithCompletion:(UIViewScreenshotAsyncCompletion)comletion;

@end
