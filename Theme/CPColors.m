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
    return [[NSColor clearColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
}

@end

@implementation NSColor (NSConnection)

+ (NSColor *)remoteCopyOfColor:(NSColor *)color
{
    NSInteger count = [color numberOfComponents];
    CGFloat components[count];
    [color getComponents:(CGFloat *)components];
    NSString *colorSpaceName = [color colorSpaceName];
    NSColorSpace *colorSpace = nil;
    
    if (colorSpaceName == NSDeviceRGBColorSpace || colorSpaceName == NSCustomColorSpace)
        colorSpace = [NSColorSpace deviceRGBColorSpace];
    else if (colorSpaceName == NSCalibratedRGBColorSpace)
        colorSpace = [NSColorSpace genericRGBColorSpace];
    else if (colorSpaceName == NSDeviceWhiteColorSpace)
        colorSpace = [NSColorSpace deviceGrayColorSpace];
    else if (colorSpaceName == NSCalibratedWhiteColorSpace)
        colorSpace = [NSColorSpace genericGrayColorSpace];
    

    return [NSColor colorWithColorSpace:colorSpace components:components count:count];
}

@end
