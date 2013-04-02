//
//  IADocument.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "IADocument.h"
#import "IADocumentWindowController.h"
#import "IANewWindowController.h"

#import "CPTheme.h"
#import <objc/objc-runtime.h>

// Tabs
#import "IAColorsViewController.h"
#import "IAGradientsViewController.h"
#import "IAImagesViewController.h"

@interface IADocument () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic, strong) NSNetServiceBrowser *servicesBrowser;

@end

@implementation IADocument
{
    NSMutableArray *_services;
    NSString *_application;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
        self.servicesBrowser = [[NSNetServiceBrowser alloc] init];
        self.servicesBrowser.delegate = self;
        [self.servicesBrowser searchForServicesOfType:@"_CPThemeServer._tcp" inDomain:@"local."];
        _services = [NSMutableArray array];
        
    }
    
    return self;
}

- (void)makeWindowControllers
{
    void (^openDocBlock)(void) = ^{
        IADocumentWindowController *windowController = [[IADocumentWindowController alloc] initWithViewControllers:
                                                        @[
                                                        [[IAColorsViewController alloc] init],
                                                        [[IAGradientsViewController alloc] init],
                                                        [[IAImagesViewController alloc] init],
                                                        ]];
        
        [self addWindowController:windowController];
        [windowController showWindow:NSApp];

        dispatch_async(dispatch_get_main_queue(), ^{
            windowController.contentController = self.contentController;
            [[NSNotificationCenter defaultCenter] addObserverForName:kMASPreferencesWindowControllerDidChangeViewNotification object:windowController queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                NSViewController <IATabViewController> *vc = [windowController selectedViewController];
                [vc.contentController bind:NSContentBinding toObject:windowController.contentController withKeyPath:[@"selection.value." stringByAppendingString:vc.identifier] options:nil];
                
                [vc.contentController addObserver:self forKeyPath:@"selection.value"
                                          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                          context:(__bridge void *)vc.identifier];
                
            }];
            [windowController.window makeKeyAndOrderFront:NSApp];

            [self.contentController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:NULL];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMASPreferencesWindowControllerDidChangeViewNotification object:windowController];
        });

    };
    
    if (!self.contentController) {
        IANewWindowController *wc = [[IANewWindowController alloc] init];
        
        __unsafe_unretained IANewWindowController *weakWc = wc;
        wc.action = ^(BOOL haveApp, NSString *appId)
        {
            self.remoteTheme = (CPTheme *)[NSConnection rootProxyForConnectionWithRegisteredName:appId host:nil];
            NSString *currentTheme = [_remoteTheme themeName];
            self.contentController = [[NSDictionaryController alloc] initWithContent:_remoteTheme.dictionaryRepresentation];
            [self.contentController setSelectionIndex:[[_contentController valueForKeyPath:@"arrangedObjects.key"] indexOfObject:currentTheme]];

            openDocBlock();
            _application = appId;
            _classes = [_remoteTheme classes];
            [self.windowControllers[1] setValue:[weakWc.contentController valueForKeyPath:@"selection.value"] forKey:@"application"];
        };
        
        [self addWindowController:wc];
        return;
    }

    openDocBlock();
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableDictionary *contentDict = [NSMutableDictionary dictionary];
    [_contentController.content enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary    *themeDict = obj;
        NSString        *themeKey = key;
        contentDict[themeKey] = [NSMutableDictionary dictionary];
        [themeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary    *propDict = obj;
            NSString        *propName = key;
            contentDict[themeKey][propName] = [NSMutableDictionary dictionary];
            [propDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSGradient class]])
                    obj = [NSGradient remoteCopyOfGradient:obj];
                else if ([obj isKindOfClass:[NSImage class]])
                    obj = [NSImage remoteCopyOfImage:obj];
                else if ([obj isKindOfClass:[NSColor class]]){
                    obj = [NSColor remoteCopyOfColor:obj];
                }
                NSObject *archived = [NSKeyedArchiver archivedDataWithRootObject:obj];
                if (!archived) {
                    NSLog(@"FFFFYCCC: %@", key);
                }
                contentDict[themeKey][propName][key] = archived;
            }];
        }];
    }];
    
    NSDictionary *saveDict = @{
                               _application:contentDict,
                               @"classes" : _classes,
                               @"selected" : [_contentController valueForKeyPath:@"selection.key"]
                               };
    
    return [NSPropertyListSerialization dataFromPropertyList:saveDict
                                                      format:NSPropertyListXMLFormat_v1_0
                                            errorDescription:nil];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSPropertyListFormat format = 0;
    NSDictionary *contentDict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    _application = [contentDict allKeys][0];
    _classes = contentDict[@"classes"];
    
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    [contentDict[_application] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *themeName = key;
        NSDictionary *themeProps = obj;
        content[themeName] = [NSMutableDictionary dictionary];
        [themeProps enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *propName = key;
            NSDictionary *props = obj;
            content[themeName][propName] = [NSMutableDictionary dictionary];
            [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                id unarchived = [[NSKeyedUnarchiver unarchiveObjectWithData:obj] copy];
                if (!unarchived) {
                    NSLog(@"fail to load %@.%@.%@", themeName, propName, key);
                } else
                    content[themeName][propName][key] = unarchived;
            }];
        }];
    }];
    
    
    self.contentController = [[NSDictionaryController alloc] initWithContent:content];
    [self.contentController setSelectionIndex:[[_contentController valueForKeyPath:@"arrangedObjects.key"] indexOfObject:contentDict[@"selected"]]];

    return YES;
}

- (void)synchronizeWithApplication;
{
    self.classes = [_remoteTheme classes];
    
    // Add new items
    NSDictionary *newThemeContent = [_remoteTheme dictionaryRepresentation];
    
    [newThemeContent enumerateKeysAndObjectsUsingBlock:^(id themeName, id theme, BOOL *stop) {
        // Add new theme
        if (![[self.contentController.content allKeys] containsObject:themeName]) {
            self.contentController.content[themeName] = theme;
        } else {
            // Synchronize content
            [theme enumerateKeysAndObjectsUsingBlock:^(id propName, id prop, BOOL *stop) {
                [prop enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (![[self.contentController.content[themeName][propName] allKeys]  containsObject:key]) {
                        NSLog(@"adding new: %@", key);
                        self.contentController.content[themeName][propName][key] = obj;
                    }
                }];
            }];
        }
    }];
    
    // Remove non exists items
    NSMutableArray *keyPaths = [NSMutableArray array];
    [self.contentController.content enumerateKeysAndObjectsUsingBlock:^(id themeName, id theme, BOOL *stop) {
        if ([[newThemeContent allKeys] containsObject:themeName]) {
            [theme enumerateKeysAndObjectsUsingBlock:^(id propName, id prop, BOOL *stop) {
                [prop enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (![[newThemeContent[themeName][propName] allKeys] containsObject:key]) {
                        [keyPaths addObject:[NSString stringWithFormat:@"%@.%@.%@", themeName, propName, key]];
                    } else if ([_remoteTheme.themeName isEqualToString:themeName]) {
                        // Update remote with current valuses
                        [_remoteTheme setValue:obj forKeyPath:[NSString stringWithFormat:@"%@.%@",  propName, key]];
                    }
                }];
            }];
        } else {
            // remove whole theme
            [keyPaths addObject:themeName];
        }
    }];
    
    [keyPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"needs to remove: %@", obj);
    }];
    
}

#pragma mark - Helpers
- (NSWindow *)window
{
    return [self windowForSheet];
}

- (IADocumentWindowController *)windowController
{
    return [self.windowForSheet windowController];
}

#pragma mark - Network browser delegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
    if ([[self windowController] isKindOfClass:[IANewWindowController class]]) {
        [[[self windowController] valueForKey:@"apps"] setObject:aNetService.name forKey:aNetService.name];
    }

    if ([[self windowController] isKindOfClass:[IADocumentWindowController class]]) {
        [[self windowController] setValue:aNetService.name forKey:@"application"];

        self.remoteTheme = (CPTheme *)[NSConnection rootProxyForConnectionWithRegisteredName:aNetService.name host:nil];
        [self synchronizeWithApplication];
    }

    [_services addObject:aNetService];
    aNetService.delegate = self;
    [aNetService startMonitoring];
    [aNetService resolveWithTimeout:5];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
    if ([[self windowController] isKindOfClass:[IANewWindowController class]]) {
        [[[self windowController] valueForKey:@"apps"] removeObjectForKey:aNetService.name];
    }
    
    if ([[self windowController] isKindOfClass:[IADocumentWindowController class]]) {
        [[self windowController] setValue:[NSNull null] forKey:@"application"];
    }
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:data];

    NSString *bundle = [[NSString alloc] initWithData:dict[@"bundle"] encoding:NSUTF8StringEncoding];
    NSString *name   = [[NSString alloc] initWithData:dict[@"name"] encoding:NSUTF8StringEncoding];
    NSString *pid    = [[NSString alloc] initWithData:dict[@"pid"] encoding:NSUTF8StringEncoding];

    if ([[self windowController] isKindOfClass:[IANewWindowController class]]) {
        [[self windowController] willChangeValueForKey:@"apps"];
        
        [[[self windowController] valueForKey:@"apps"] setObject:[NSString stringWithFormat:@"%@ (%@)", name, pid] forKey:bundle];
        [[self windowController] didChangeValueForKey:@"apps"];
    }
    
    if ([[self windowController] isKindOfClass:[IADocumentWindowController class]]) {
        [[self windowController] setValue:[NSString stringWithFormat:@"%@ (%@)", name, pid] forKey:@"application"];
    }
    
    [sender stopMonitoring];

    [sender stop];
    [_services removeObject:sender];
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selection"]) {
        
        NSViewController <IATabViewController> *vc = [(IADocumentWindowController *)[[self windowForSheet] windowController] selectedViewController];
        [vc.contentController removeObserver:self forKeyPath:@"selection.value"];

        [_remoteTheme setThemeName:[_contentController valueForKeyPath:@"selection.key"]];
        
        [vc.contentController addObserver:self forKeyPath:@"selection.value"
                                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                  context:(__bridge void *)vc.identifier];
    } else {
        NSString *remoteKeyPath = [NSString stringWithFormat:@"%@.%@", context, [object valueForKeyPath:@"selection.key"]];
        [_remoteTheme setValue:[object valueForKeyPath:keyPath] forKeyPath:remoteKeyPath];
    }
}

@end
