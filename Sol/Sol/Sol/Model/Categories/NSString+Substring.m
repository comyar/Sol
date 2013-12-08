//
//  NSString+Substring.m
//  Sol
//
//  Created by Comyar Zaheri on 8/10/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#import "NSString+Substring.h"

@implementation NSString (Substring)

- (BOOL)contains:(NSString *)substring
{
    if([self rangeOfString:substring].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
