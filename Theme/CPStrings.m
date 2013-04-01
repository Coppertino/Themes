//
//  CPStrings.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPStrings.h"

@implementation CPStrings

- (id)valueForUndefinedKey:(NSString *)key
{
    return NSLocalizedString(@"Undefined string", @"");
}

@end
