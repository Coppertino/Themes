//
//  IAGradientsViewController.m
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "IAGradientsViewController.h"
#import "CPGradients.h"

@interface IAGradientsViewController ()

@end

@implementation IAGradientsViewController
@synthesize tableView = _tableView;
@synthesize contentController = _contentController;

- (NSString *)nibName { return NSStringFromClass(self.class); }
- (NSString *)identifier { return @"gradients"; }
- (NSString *)toolbarItemLabel { return @"Gradients"; }
- (NSImage *)toolbarItemImage { return [NSImage imageNamed:NSImageNameColorPanel]; }

#pragma mark - Table Delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [tableView makeViewWithIdentifier:@"MainCell" owner:self];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    NSGradient *curValue = [NSGradient remoteCopyOfGradient:[_contentController valueForKeyPath:@"selection.value"]];

    [self.gradientEditor setGradient:curValue];
    [self.gradientView setGradient:curValue];
    self.gradientEditor.delegate = self;
}

- (void)GradientEditorChangedGradient:(ACTGradientEditor *)editor {
    [self.gradientView setGradient:editor.gradient];
    [_contentController setValue:editor.gradient forKeyPath:@"selection.value"];
}


@end
