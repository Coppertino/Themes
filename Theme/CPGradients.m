//
//  CPGradients.m
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "CPGradients.h"

@implementation CPGradients

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([value isKindOfClass:[NSGradient class]]) {
        value = [NSGradient remoteCopyOfGradient:value];
    }
    
    [super setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [[NSGradient alloc] initWithColors:@[[NSColor redColor], [NSColor whiteColor]]];
}

@end

@implementation NSGradient (NSConnection)

+ (NSGradient *)remoteCopyOfGradient:(NSGradient *)inGradient
{
	NSInteger			aNumberOfStops = [inGradient numberOfColorStops];
	NSMutableArray *	aColorList = [NSMutableArray array];
	CGFloat				aLocationList[aNumberOfStops];
	
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)	{
        
		NSColor *	aStopColor = nil;
		CGFloat		aLocation = 0;
		[inGradient getColor:&aStopColor location:&aLocation atIndex:i];
		
		[aColorList addObject:[NSColor colorWithDeviceRed:aStopColor.redComponent green:aStopColor.greenComponent blue:aStopColor.blueComponent alpha:aStopColor.alphaComponent]];
		aLocationList[i] = aLocation;
	}
    
	NSGradient * outGradient = [[NSGradient alloc] initWithColors:aColorList atLocations:aLocationList colorSpace:[NSColorSpace sRGBColorSpace]];
    return outGradient;
}

@end
