//
//  CPAbstractTheme.h
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPColors.h"
#import "CPGradients.h"
#import "CPImages.h"
#import "CPShadows.h"
#import "CPStrings.h"

@interface CPTheme : NSObject

@property (nonatomic, strong) NSString *themeName;

+ (instancetype)sharedTheme;
+ (Class)colorsClass;
+ (Class)gradientsClass;
+ (Class)imagesClass;
+ (Class)shadowsClass;
+ (Class)stringsClass;

- (CPColors *)colors;
- (CPGradients *)gradients;
- (CPImages *)images;
- (CPShadows *)shadows;
- (CPStrings *)strings;

- (NSArray *)availableThemes;
- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)classes;

- (void)forceUpdate;
- (void)allowRemoteConnections;

@end
