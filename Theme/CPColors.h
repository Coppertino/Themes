//
//  CPColors.h
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPColors.h"
#import "CPThemeItem.h"

@interface CPColors : CPThemeItem

@end


@interface NSColor (NSConnection)

+ (NSColor *)remoteCopyOfColor:(NSColor *)color;

@end