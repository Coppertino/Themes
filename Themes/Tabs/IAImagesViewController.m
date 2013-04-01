//
//  IAImagesViewController.m
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "IAImagesViewController.h"

@interface IAImagesViewController ()

@end

@implementation IAImagesViewController
@synthesize tableView = _tableView;
@synthesize contentController = _contentController;

- (NSString *)nibName { return NSStringFromClass(self.class); }
- (NSString *)identifier { return @"images"; }
- (NSString *)toolbarItemLabel { return @"Images"; }
- (NSImage *)toolbarItemImage { return [NSImage imageNamed:NSImageNameApplicationIcon]; }
- (void)viewWillAppear
{
    [_tableView reloadData];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}
//
//#pragma mark - Table View DataSource
//- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
//{
//    return _objectsArray.count;
//}
//
//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
//{
//    return _objectsArray[row];
//}
//
#pragma mark - Table View Delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [tableView makeViewWithIdentifier:@"MainCell" owner:self];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    NSImage *selectedImage = [_contentController valueForKeyPath:@"selection.value"];
    if ([selectedImage name]) {
        selectedImage = [NSImage imageNamed:selectedImage.name];
    } else {

        NSArray *reps = [selectedImage representations];
        selectedImage = [[NSImage alloc] initWithSize:selectedImage.size];
        [reps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSBitmapImageRep class]]) {
                NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithData:[obj TIFFRepresentation]];
                [selectedImage addRepresentation:newRep];
            }
        }];
    }
    
    NSSize imageSize = selectedImage.size;
    NSBitmapImageRep    *normalBM = nil,
                        *retinaBM = nil;
    
    for (NSImageRep *rep in selectedImage.representations) {
        if (rep.pixelsHigh == imageSize.height && rep.pixelsWide == imageSize.width)
            normalBM = (NSBitmapImageRep *)rep;
        else if (rep.pixelsHigh == (imageSize.height * 2) && rep.pixelsWide == (imageSize.width * 2))
            retinaBM = (NSBitmapImageRep *)rep;
    }
    
    NSImage *newNormalImage = [[NSImage alloc] initWithSize:imageSize];
    [newNormalImage addRepresentation:normalBM];
    self.imageView.image = newNormalImage;
    
    NSImage *newRetinaImage = [[NSImage alloc] initWithSize:NSMakeSize(2*imageSize.width, 2*imageSize.height)];
    [newRetinaImage addRepresentation:retinaBM];
    self.retinaImageView.image = newRetinaImage;
    
}


- (IBAction)updateNormalImage:(id)sender {
    NSImage *image = [_contentController valueForKeyPath:@"selection.value"];
    NSMutableArray *reps = [[image representations] mutableCopy];

    NSImage *newImage = [[NSImage alloc] initWithSize:[sender image].size];
    NSSize newImageSize = newImage.size;

    [image.representations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSImageRep *)obj pixelsWide] != (newImageSize.width  *2) ||
            [(NSImageRep *)obj pixelsHigh] != (newImageSize.height *2)) {
            [reps removeObject:obj];
        }
    }];

    NSBitmapImageRep *newRep = [[sender image] representations][0];
    [newImage addRepresentation:newRep];
    [newImage addRepresentations:reps];
    
    [_contentController setValue:newImage forKeyPath:@"selection.value"];
}



- (IBAction)updateRetinaImage:(id)sender {
    NSImage *image = [_contentController valueForKeyPath:@"selection.value"];
    NSSize imageSize = image.size;
    NSMutableArray *reps = [[image representations] mutableCopy];
    [image.representations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSImageRep *)obj pixelsWide] != (imageSize.width  ) ||
            [(NSImageRep *)obj pixelsHigh] != (imageSize.height)) {
            [reps removeObject:obj];
        }
    }];
    
    NSBitmapImageRep *newRep = [[sender image] representations][0];
    NSImage *newImage = [[NSImage alloc] initWithSize:image.size];
    
    [newImage addRepresentations:reps];
    [newImage addRepresentation:newRep];
    
    [_contentController setValue:newImage forKeyPath:@"selection.value"];
}

@end
