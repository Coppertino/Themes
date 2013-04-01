
//
//  main.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IADocument.h"
#import "CPTheme.h"

static NSString *stringForKeyWithColor(NSString *key, NSColor *color) {
    return [NSString stringWithFormat:@"- (NSColor *)%@ { return [NSColor colorWithDeviceRed:%f green:%f blue:%f alpha:%f]; }\n",
            key,
            color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent];
};

static NSString *stringForKeyWithGradient(NSString *key, NSGradient *gradient) {
    
    NSInteger			aNumberOfStops = [gradient numberOfColorStops];
	NSMutableArray *	aColorList = [NSMutableArray array];
	CGFloat				aLocationList[aNumberOfStops];
	
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)	{
        
		NSColor *	aStopColor = nil;
		CGFloat		aLocation = 0;
		[gradient getColor:&aStopColor location:&aLocation atIndex:i];
		
		[aColorList addObject:[NSColor colorWithDeviceRed:aStopColor.redComponent green:aStopColor.greenComponent blue:aStopColor.blueComponent alpha:aStopColor.alphaComponent]];
		aLocationList[i] = aLocation;
	}

    
    
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"- (NSGradient *)%@\n{\n", key];
    
    // Fillup colors
    [string appendFormat:@"\tNSArray *colors = @[\n"];
    [aColorList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       [string appendFormat:@"\t\t[NSColor colorWithDeviceRed:%f green:%f blue:%f alpha:%f],\n",
        [obj redComponent],
        [obj greenComponent],
        [obj blueComponent],
        [obj alphaComponent]
        ];
    }];
    
    [string appendFormat:@"\t];\n\n"];

    // Fillup locations
    [string appendFormat:@"\tCGFloat locations[%li] = { ", aNumberOfStops];
    for (int i = 0; i < aNumberOfStops; i++) {
        [string appendFormat:@" %f%@ ", aLocationList[i], ((i+1) < aNumberOfStops) ? @"," : @""];
    }
    [string appendFormat:@"};\n\n"];
    
    // Finalize
	[string appendString:@"\t return [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];\n\n"];
    [string appendFormat:@"}\n"];
    
    return [NSString stringWithString:string];
};

static NSString *stringForImageWithKeyforPath(NSString *key, NSImage *image, NSString *outputDir, NSString *suffix)
{
    if (!image)
        return [NSString stringWithFormat:@"- (NSImage *)%@ { return nil; }\n", key];

    if (image.name) {
        return [NSString stringWithFormat:@"- (NSImage *)%@; { return [NSImage imageNamed:@\"%@\"]; }\n", key, image.name];
    }
    [[image representations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSBitmapImageRep class]]) {
            NSBitmapImageRep *rep = obj;
            
            NSString *fileName = key;
            if (suffix) {
                fileName = [fileName stringByAppendingString:suffix];
            }
            // if retina
            if (rep.pixelsHigh / 2 == image.size.height && rep.pixelsWide/2 == image.size.width) {
                fileName = [fileName stringByAppendingString:@"@2x"];
            }
            fileName = [fileName stringByAppendingPathExtension:@"png"];

            [[rep representationUsingType:NSPNGFileType properties:nil] writeToFile:[outputDir stringByAppendingPathComponent:fileName] atomically:YES];
            NSLog(@"%@", fileName);
        } else {
            NSLog(@"fail to save image rep: %@", obj);
        }
    }];
    return [NSString stringWithFormat:@"- (NSImage *)%@; { return [NSImage imageNamed:@\"%@\"]; }\n", key, [key stringByAppendingString:suffix ? suffix : @""]];
}

int main(int argc, char *argv[])
{
    NSString *themePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"theme"];
    NSString *outputDir = [[NSUserDefaults standardUserDefaults] valueForKey:@"output"];
    if (themePath && outputDir && [[NSFileManager defaultManager] fileExistsAtPath:themePath])
    {
        IADocument *doc = [[IADocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:themePath] ofType:nil error:NULL];
        NSDictionary *dict = [doc.contentController content];
        doc = nil;
        
        NSPropertyListFormat format;
        NSDictionary *content = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:themePath] mutabilityOption:NSPropertyListImmutable format:&format errorDescription:NULL];
        
        NSDictionary *classes = content[@"classes"];
        content = nil;

        NSString *filePath = [outputDir stringByAppendingPathComponent:[[[themePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"m"]];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        NSFileHandle *f = [NSFileHandle fileHandleForWritingAtPath:filePath];

        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *suffix = nil;
            if (![[dict allKeys][0] isEqualToString:key]) {
                suffix = key;
            }
            
            NSDictionary *theme = obj;
            [theme enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *className = classes[key];
                if ([NSClassFromString(className) superclass] != [CPThemeItem class])
                {
                    if (suffix) {
                        className = [[className stringByAppendingString:@"_"] stringByAppendingString:suffix];
                    }
                    
                    // Begin of file
                    [f writeData:[[NSString stringWithFormat:@"#import \"%@.h\"\n\n", suffix ? classes[key] : className] dataUsingEncoding:NSUTF8StringEncoding]];
                    if (suffix) {
                        [f writeData:[[NSString stringWithFormat:@"@interface %@ : %@\n\n@end\n\n", className, classes[key]] dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    [f writeData:[[NSString stringWithFormat:@"@implementation %@\n\n", className] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    // Content
                    if ([key isEqualToString:@"colors"]) {
                        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            [f writeData:[stringForKeyWithColor(key, obj) dataUsingEncoding:NSUTF8StringEncoding]];
                        }];
                    }
                    else if ([key isEqualToString:@"gradients"]) {
                        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            [f writeData:[stringForKeyWithGradient(key, obj) dataUsingEncoding:NSUTF8StringEncoding]];
                        }];
                    }
                    else if ([key isEqualToString:@"images"]) {
                        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            [f writeData:[stringForImageWithKeyforPath(key, obj, outputDir, suffix) dataUsingEncoding:NSUTF8StringEncoding]];
                        }];
                    }
                    
                    // End of file
                    [f writeData:[@"\n@end\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
            }];
            
        }];

        [f synchronizeFile];
        [f closeFile];
        
        return 0;
    }
    return NSApplicationMain(argc, (const char **)argv);
}
