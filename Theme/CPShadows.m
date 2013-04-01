//
//  CPShadows.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPShadows.h"

@implementation CPShadows

- (id)valueForUndefinedKey:(NSString *)key
{
    return [[NSShadow alloc] init];
}

@end
