//
//  CPColors.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPColors.h"
#import <objc/objc-runtime.h>

@implementation CPColors
- (id)valueForUndefinedKey:(NSString *)key
{
    return [NSColor clearColor];
}

@end
