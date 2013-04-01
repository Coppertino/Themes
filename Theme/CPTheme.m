//
//  CPAbstractTheme.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPTheme.h"
#import <objc/objc-runtime.h>

static NSString * const kCPThemeClassNameKey = @"CPThemeClassNameKey";

@interface CPThemeItem (sharedItem)

+ (instancetype)sharedItem;

@end

@interface CPTheme () <NSNetServiceDelegate>

@property (strong) CPColors     *colors;
@property (strong) CPImages     *images;
@property (strong) CPShadows    *shadows;
@property (strong) CPGradients  *gradients;
@property (strong) CPStrings    *strings;

@property (nonatomic, strong) NSConnection *connection;
@property (nonatomic, strong) NSNetService *server;

@end

@implementation CPTheme

+ (CPTheme *)sharedTheme
{
    static CPTheme *_sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTheme = [[self alloc] init];
    });
    
    return _sharedTheme;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self bind:@"themeName" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kCPThemeClassNameKey] options:nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kCPThemeClassNameKey : NSStringFromClass(self.class) }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceUpdate) name:@"CPThemeDidChange" object:nil];
    }
    
    return self;
}

+ (Class)colorsClass;
{
    return [CPColors class];
}

+ (Class)gradientsClass;
{
    return [CPGradients class];
}

+ (Class)imagesClass;
{
    return [CPImages class];
}

+ (Class)shadowsClass;
{
    return [CPShadows class];
}

+ (Class)stringsClass;
{
    return [CPStrings class];
}

+ (Class)themedClassForClass:(Class)aClass andThemeName:(NSString *)aTheme;
{
    if (NSClassFromString(aTheme) == [self class] || !aClass || !aTheme)
        return aClass;
    
    NSString *newClassName = [NSStringFromClass(aClass) stringByAppendingFormat:@"_%@", aTheme];
    Class newClass = NSClassFromString(newClassName);
    if (newClass)
        return newClass;
    
    // Create class on fly
    newClass = objc_allocateClassPair(aClass, [newClassName UTF8String], 0);
    objc_registerClassPair(newClass);
    
    return newClass;
}

- (NSArray *)availableThemes
{
    return @[NSStringFromClass(self.class)];
}

- (NSDictionary *)dictionaryRepresentation;
{
    NSMutableDictionary *reps = [NSMutableDictionary dictionaryWithCapacity:self.availableThemes.count];
    [self.availableThemes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        NSString *themeName = obj;
        reps[themeName] = @{
                            @"colors" : [NSMutableDictionary dictionary],
                            @"gradients" : [NSMutableDictionary dictionary],
                            @"images" : [NSMutableDictionary dictionary],
                            @"shadows" : [NSMutableDictionary dictionary],
                            @"strings" : [NSMutableDictionary dictionary],
                            };
        Class colorsClass       = [self.class themedClassForClass:[self.class colorsClass] andThemeName:themeName];
        Class gradientsClass    = [self.class themedClassForClass:[self.class gradientsClass] andThemeName:themeName];
        Class imagesClass       = [self.class themedClassForClass:[self.class imagesClass] andThemeName:themeName];
        Class shadowsClass      = [self.class themedClassForClass:[self.class shadowsClass] andThemeName:themeName];
        Class stringsClass      = [self.class themedClassForClass:[self.class stringsClass] andThemeName:themeName];

        CPColors *colors = [colorsClass sharedItem];
        [colors.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            reps[themeName][@"colors"][obj] = [colors valueForKey:obj];
        }];

        CPGradients *gradients = [gradientsClass sharedItem];
        [gradients.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            reps[themeName][@"gradients"][obj] = [gradients valueForKey:obj];
        }];

        CPImages *images = [imagesClass sharedItem];
        [images.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            reps[themeName][@"images"][obj] = [images valueForKey:obj];
        }];

        CPShadows *shadows = [shadowsClass sharedItem];
        [shadows.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            reps[themeName][@"shadows"][obj] = [shadows valueForKey:obj];
        }];

        CPStrings *strings = [stringsClass sharedItem];
        [strings.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            reps[themeName][@"strings"][obj] = [strings valueForKey:obj];
        }];
    }];
    
    return [NSDictionary dictionaryWithDictionary:reps];
}

- (NSDictionary *)classes
{
    Class colorsClass       = [self.class themedClassForClass:[self.class colorsClass] andThemeName:NSStringFromClass(self.class)];
    Class gradientsClass    = [self.class themedClassForClass:[self.class gradientsClass] andThemeName:NSStringFromClass(self.class)];
    Class imagesClass       = [self.class themedClassForClass:[self.class imagesClass] andThemeName:NSStringFromClass(self.class)];
    Class shadowsClass      = [self.class themedClassForClass:[self.class shadowsClass] andThemeName:NSStringFromClass(self.class)];
    Class stringsClass      = [self.class themedClassForClass:[self.class stringsClass] andThemeName:NSStringFromClass(self.class)];

    return @{
             @"colors"     : NSStringFromClass(colorsClass),
             @"gradients"  : NSStringFromClass(gradientsClass),
             @"images"     : NSStringFromClass(imagesClass),
             @"shadows"    : NSStringFromClass(shadowsClass),
             @"strings"    : NSStringFromClass(stringsClass),
             };
}

- (void)setThemeName:(NSString *)themeName
{
    if (![self.availableThemes containsObject:themeName])
        return;
    
    _themeName = themeName;
    
    Class colorsClass       = [self.class themedClassForClass:[self.class colorsClass] andThemeName:themeName];
    Class gradientsClass    = [self.class themedClassForClass:[self.class gradientsClass] andThemeName:themeName];
    Class imagesClass       = [self.class themedClassForClass:[self.class imagesClass] andThemeName:themeName];
    Class shadowsClass      = [self.class themedClassForClass:[self.class shadowsClass] andThemeName:themeName];
    Class stringsClass      = [self.class themedClassForClass:[self.class stringsClass] andThemeName:themeName];
    
    self.colors     = [colorsClass sharedItem];
    self.gradients  = [gradientsClass sharedItem];
    self.images     = [imagesClass sharedItem];
    self.shadows    = [shadowsClass sharedItem];
    self.strings    = [stringsClass sharedItem];
    
    [self forceUpdate];
}

- (void)forceUpdate;
{
    [[NSApp windows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(NSView *)[obj contentView] setNeedsDisplayInRect:[[obj contentView] bounds]];
        [obj flushWindow];
    }];
    
    
}

- (void)allowRemoteConnections;
{
    _server = [[NSNetService alloc] initWithDomain:@"local." type:@"_CPThemeServer._tcp" name:[[NSBundle mainBundle] bundleIdentifier] port:65535];
    if (_server) {
        [_server setTXTRecordData:[NSNetService dataFromTXTRecordDictionary:@{
                                   @"bundle" : [[NSBundle mainBundle] bundleIdentifier],
                                   @"name" : [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleNameKey],
                                   @"pid" : [NSString stringWithFormat:@"%i", [[NSProcessInfo processInfo] processIdentifier]]
                                   }]];
        _server.delegate = self;
        [_server publish];
    }
}

- (NSArray *)exposedBindings;
{
    return @[@"colors", @"images", @"shadows", @"gradients", @"strings"];
}

- (void)didChangeValueForKey:(NSString *)key
{
    [super didChangeValueForKey:key];
//    [[NSApp windows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [(NSView *)[obj contentView] setNeedsDisplayInRect:[[obj contentView] bounds]];
//    }];
}

- (Class)valueClassForBinding:(NSString *)binding
{
    if ([binding isEqualToString:@"colors"])
        return [self.class colorsClass];
    if ([binding isEqualToString:@"images"])
        return [self.class imagesClass];
    if ([binding isEqualToString:@"shadows"])
        return [self.class shadowsClass];
    if ([binding isEqualToString:@"gradients"])
        return [self.class gradientsClass];
    if ([binding isEqualToString:@"strings"])
        return [self.class stringsClass];
    
    return nil;
}

#pragma mark - NetService delegate
- (void)netServiceWillPublish:(NSNetService *)sender;
{
    _connection = [[NSConnection alloc] init];
    [_connection setRootObject:self];
    [_connection registerName:[[NSBundle mainBundle] bundleIdentifier]];
    NSLog(@"start connection: %@", [[NSBundle mainBundle] bundleIdentifier]);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
{
    NSLog(@"%@ %@ %@", NSStringFromSelector(_cmd), sender, errorDict);
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    [_connection invalidate];
    _connection = nil;
}


@end
