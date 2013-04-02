//
//  CPThemeItem.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPThemeItem.h"
#import <objc/objc-runtime.h>

@implementation CPThemeItem
{
    NSMutableDictionary *_customValues;
}

+ (instancetype)sharedItem
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [NSMutableDictionary dictionary];
    });
    
    NSString *className = NSStringFromClass(self);

    if (!_sharedObject[className]) {
        _sharedObject[className] = [[self alloc] init];
    }
    
    return _sharedObject[className];
}

- (id)init
{
    self = [super init];
    if (self) {
        _customValues = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)valueForKey:(NSString *)key
{
    if ([_customValues.allKeys containsObject:key])
    {
        return _customValues[key];
    }
    
    id obj = [super valueForKey:key];

    if (!obj) {
        obj = [self valueForUndefinedKey:key];
    }
    
    return obj;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([self.allValues containsObject:key]) {
        [self willChangeValueForKey:key];
        _customValues[key] = value;
        
        SEL selector = NSSelectorFromString(key);
        Method m = class_getInstanceMethod([self class], selector);
        IMP newImplementation = imp_implementationWithBlock(^(id aSelf) {
            return value;
        });
        
        method_setImplementation(m, newImplementation);
        
        
        [self didChangeValueForKey:key];
    }
}

- (void)didChangeValueForKey:(NSString *)key
{
    [super didChangeValueForKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CPThemeDidChange" object:nil];
}


- (NSArray *)allValues
{
    unsigned int propertyCount = 0;
    Class targetClass = [self class];
    if ([self.superclass superclass] != [CPThemeItem class]) {
        targetClass = [self superclass];
    }
    
    objc_property_t * properties = class_copyPropertyList(targetClass, &propertyCount);
    
    NSMutableArray * propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    
    return propertyNames;
}


@end
