//
//  COPDefaultTheme.h
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPTheme.h"
#import "COPDefaultColors.h"
#import "COPDefaultGradients.h"
#import "COPDefaultImages.h"

@class COPDefaultTheme;
extern COPDefaultTheme *COPTheme;

@interface COPDefaultTheme : CPTheme

@property (nonatomic) COPDefaultColors *colors;
@property (nonatomic) COPDefaultGradients *gradients;
@property (nonatomic) COPDefaultImages *images;

@end
