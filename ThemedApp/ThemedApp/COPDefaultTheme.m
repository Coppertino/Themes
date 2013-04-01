//
//  COPDefaultTheme.m
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "COPDefaultTheme.h"

COPDefaultTheme * COPTheme;

@implementation COPDefaultTheme

+ (void)load
{
    COPTheme = (COPDefaultTheme *)[COPDefaultTheme sharedTheme];
}

+ (Class)colorsClass  { return [COPDefaultColors class]; }
+ (Class)gradientsClass  { return [COPDefaultGradients class]; }
+ (Class)imagesClass { return [COPDefaultImages class]; }

- (NSArray *)availableThemes
{
    return @[NSStringFromClass(self.class), @"Custom"];
}


@end
