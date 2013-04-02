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
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    
    if ([color.colorSpaceName isEqualToString:NSCalibratedRGBColorSpace] || [color.colorSpaceName isEqualToString:NSDeviceRGBColorSpace]) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    } else if ([color.colorSpaceName isEqualToString:NSCalibratedWhiteColorSpace] || [color.colorSpaceName isEqualToString:NSDeviceWhiteColorSpace]) {
        [color getWhite:&red alpha:&alpha];
        green = blue = red;
    }
    
    return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}

@end
