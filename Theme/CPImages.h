//
//  CPImages.h
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPThemeItem.h"

@interface CPImages : CPThemeItem

@end

@interface NSImage (NSConnection)

+ (NSImage *)remoteCopyOfImage:(NSImage *)inImage;

@end