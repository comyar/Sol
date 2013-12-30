//
//  CZDebug.h
//  Sol
//
//  Created by Comyar Zaheri on 9/20/13.
//  Copyright (c) 2013 Comyar Zaheri. All rights reserved.
//

#ifndef CZDebug
#define CZDebug

#define CZDEBUG_ENABLED YES
#define CZLog(class, ...) if(CZDEBUG_ENABLED) NSLog(@"["class"] - "__VA_ARGS__)

#endif
