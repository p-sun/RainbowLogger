//
//  FilterCell.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

- (void)awakeFromNib {
    [FilterColor.allColors
     enumerateObjectsUsingBlock:^(FilterColor* filterColor, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:filterColor.name action:nil keyEquivalent:@""];
        menuItem.image = [self swatchForColor:filterColor.color];
        [self.colorsPopup.menu addItem:menuItem];
    }];
}

- (IBAction)deleteButtonPressed:(id)sender {
    _onDelete();
}

- (IBAction)enableToggled:(NSButton *)sender {
    _onEnableToggle(sender.state == NSControlStateValueOn);
}

- (NSImage *)swatchForColor:(NSColor *)color {
    NSSize size = NSMakeSize(12, 12);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [color drawSwatchInRect:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    return image;
}

- (void)setFilter:(Filter *)filter {
    self.filterByText.stringValue = filter.text;
    self.isEnabledToggle.state = filter.isEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    [self.colorsPopup selectItemWithTag:filter.colorTag];
    [self.filterByPopup selectItemWithTag:filter.type];
}

@end
