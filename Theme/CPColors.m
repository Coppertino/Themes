//
//  CPColors.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPColors.h"

@implementation CPColors
- (id)valueForUndefinedKey:(NSString *)key
{
    return [NSColor clearColor];
}

@end

@implementation NSColor (NSConnection)

+ (NSColor *)remoteCopyOfColor:(NSColor *)color
{
    NSColorSpace *colorSpace = [color colorSpace];
    color = [color colorUsingColorSpace:colorSpace];

    NSInteger count = [color numberOfComponents];
    CGFloat components[count];
    [color getComponents:(CGFloat *)components];
   
    return [NSColor colorWithColorSpace:[NSColorSpace deviceRGBColorSpace] components:components count:count];
}

@end
