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
    [Filter.allFilterByTypes enumerateObjectsUsingBlock:^(FilterTypePopupInfo* info, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:info.name action:nil keyEquivalent:@""];
        menuItem.tag = idx;
        [_filterByPopup.menu addItem:menuItem];
    }];
    [Filter.allColors
     enumerateObjectsUsingBlock:^(FilterColorPopupInfo* info, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:info.name action:nil keyEquivalent:@""];
        menuItem.image = [self swatchForColor:info.color];
        menuItem.tag = idx;
        [_colorsPopup.menu addItem:menuItem];
    }];
}

- (IBAction)deleteButtonPressed:(id)sender {
    _onDelete();
}

- (IBAction)enableToggled:(NSButton *)sender {
    _filter.isEnabled = sender.state == NSControlStateValueOn;
    _onFilterChanged(_filter);
}

- (IBAction)filterByChanged:(NSPopUpButton *)sender {
    _filter.type = sender.tag;
    _onFilterChanged(_filter);
}

- (IBAction)colorChanged:(NSPopUpButton *)sender {
    _filter.colorTag = sender.tag;
    _onFilterChanged(_filter);
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
    
    _filter = filter;
}

@end
