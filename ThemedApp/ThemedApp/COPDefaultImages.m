//
//  COPDefaultImages.m
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "COPDefaultImages.h"

@implementation COPDefaultImages

- (NSImage *)userImage; { return [NSImage imageNamed:NSImageNameEveryone]; }
- (NSImage *)someImage; { return [[NSImage alloc] initWithContentsOfFile:@"/Users/acrist/Desktop/Img1 3.png"]; }

@end
