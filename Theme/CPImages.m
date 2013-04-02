//
//  CPImages.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPImages.h"

@implementation CPImages

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSImage class]]) {
        value = [NSImage remoteCopyOfImage:value];
    }
    
    [super setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [NSImage imageNamed:@"NSCaution"];
}

@end

@implementation NSImage (NSConnection)

+ (NSImage *)remoteCopyOfImage:(NSImage *)inImage
{
    NSImage *newImage = nil;
    if ([inImage.representations[0] isKindOfClass:[NSBitmapImageRep class]])
    {
        NSArray *reps = [inImage representations];
        newImage = [[NSImage alloc] initWithSize:inImage.size];
        [reps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSBitmapImageRep class]]) {
                NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithData:[obj TIFFRepresentation]];
                [newImage addRepresentation:newRep];
            }
        }];
        if (inImage.name)
            newImage.name = inImage.name;
        
    } else if ([inImage isTemplate] && [inImage.representations[0] isKindOfClass:[NSPDFImageRep class]]) {
        newImage = [[NSImage alloc] initWithData:[(NSPDFImageRep *)inImage.representations[0] PDFRepresentation]];
        [newImage setTemplate:YES];
        if (inImage.name)
            newImage.name = inImage.name;
        
    } else if (inImage.name) {
        newImage = [NSImage imageNamed:inImage.name];
    }
    
    return newImage;
}

@end