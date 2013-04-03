//
//  main.m
//  themegen
//
//  Created by Ivan Ablamskyi on 02.04.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//
/*
 * MIT License:
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CPTheme.h"


static NSString *stringForKeyWithColor(NSString *key, NSColor *color) {
    color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
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
        aStopColor =[aStopColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
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

static NSString *stringForImageWithKeyforPath(NSString *key, NSImage *image, NSString *suffix)
{
    if (!image)
        return [NSString stringWithFormat:@"- (NSImage *)%@ { return nil; }\n", key];
    if (image.name && ![image.representations[0] isKindOfClass:[NSBitmapImageRep class]]) {
        return [NSString stringWithFormat:@"- (NSImage *)%@; { return [NSImage imageNamed:@\"%@\"]; }\n", key, image.name];
    }
    
    NSString *imageFile = [key stringByAppendingString:suffix ? suffix : @""];
    if ([image.representations[0] isKindOfClass:[NSPDFImageRep class]]) {
        imageFile = [imageFile stringByReplacingOccurrencesOfString:@"template"
                                             withString:@""
                                                options:NSCaseInsensitiveSearch
                                                  range:NSMakeRange(0, key.length)];
        imageFile = [imageFile stringByAppendingString:@"Template"];

    }
    
   
    return [NSString stringWithFormat:@"- (NSImage *)%@; { return [NSImage imageNamed:@\"%@\"]; }\n", key, imageFile];
}

static void exportImageForKeyToPathAsTIFF(NSImage *image, NSString *key, NSString *path, NSString *suffix, BOOL isTIFF)
{
    if (!image)
        return;
    NSString *fileName = key;
    if (suffix) {
        fileName = [fileName stringByAppendingString:suffix];
    }

    if ([image.representations[0] isKindOfClass:[NSPDFImageRep class]]) {
        fileName = [fileName stringByReplacingOccurrencesOfString:@"template"
                                                       withString:@""
                                                          options:NSCaseInsensitiveSearch
                                                            range:NSMakeRange(0, fileName.length)];
        fileName = [fileName stringByAppendingString:@"Template"];
        fileName = [fileName stringByAppendingPathExtension:@"pdf"];
        [[image.representations[0] PDFRepresentation] writeToFile:[path stringByAppendingPathComponent:fileName] atomically:YES];

    } else if (isTIFF) {
        fileName = [fileName stringByAppendingPathExtension:@"tiff"];
        [[image TIFFRepresentation] writeToFile:[path stringByAppendingPathComponent:fileName] atomically:YES];
        
    } else {
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
                
                [[rep representationUsingType:NSPNGFileType properties:nil] writeToFile:[path stringByAppendingPathComponent:fileName] atomically:YES];
                
            } else {
            }
        }];
    }
}


static void exportCodeFromContentToFile(NSDictionary *dict, NSDictionary *classes, NSString *filePath)
{
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
                        [f writeData:[stringForImageWithKeyforPath(key, obj, suffix) dataUsingEncoding:NSUTF8StringEncoding]];
                    }];
                }
                
                // End of file
                [f writeData:[@"\n@end\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
        }];
        
    }];
    
    [f synchronizeFile];
    [f closeFile];

}


static void exportResourcesFromContentToPath(NSDictionary *dict, NSDictionary *classes, NSString *filePath)
{
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
                
                if ([key isEqualToString:@"images"]) {
                    [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        exportImageForKeyToPathAsTIFF(obj, key, filePath, suffix, ([[NSUserDefaults standardUserDefaults] valueForKey:@"useTIFF"] != nil));
                    }];
                }
                
            }
            
        }];
    }];
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString *themePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"theme"];
        NSString *outputDir = [[NSUserDefaults standardUserDefaults] valueForKey:@"output"];
        if (themePath && outputDir && [[NSFileManager defaultManager] fileExistsAtPath:themePath])
        {
            
            NSPropertyListFormat format;
            NSDictionary *content = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:themePath] mutabilityOption:NSPropertyListImmutable format:&format errorDescription:NULL];

            NSString *application = [content allKeys][0];
            NSDictionary *classes = content[@"classes"];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [content[application] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *themeName = key;
                NSDictionary *themeProps = obj;
                dict[themeName] = [NSMutableDictionary dictionary];
                [themeProps enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSString *propName = key;
                    NSDictionary *props = obj;
                    dict[themeName][propName] = [NSMutableDictionary dictionary];
                    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        dict[themeName][propName][key] = [[NSKeyedUnarchiver unarchiveObjectWithData:obj] copy];
                    }];
                }];
            }];
            

            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"exportResources"])
            {
                exportResourcesFromContentToPath(dict, classes, outputDir);
            }
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"exportTheme"])
            {
                NSString *filePath = [outputDir stringByAppendingPathComponent:[[[themePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"m"]];
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                exportCodeFromContentToFile(dict, classes, filePath);
            }

            return 0;
        }
        
    }
    return 0;
}

