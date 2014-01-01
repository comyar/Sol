//
//  UIView+Screenshot.m
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)screenshot
{
    CGSize size = self.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)screenshotAsyncWithCompletion:(UIViewScreenshotAsyncCompletion)comletion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        CGSize size = self.bounds.size;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [self.layer renderInContext:context];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        dispatch_sync(dispatch_get_main_queue(), ^ {
            comletion(image);
        });
    });
}

@end
