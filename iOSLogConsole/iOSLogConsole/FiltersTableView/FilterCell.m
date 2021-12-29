//
//  FilterCell.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterCell.h"
#import "Filter.h"

@implementation FilterCell

- (void)awakeFromNib {
    NSPopUpButtonCell *cell = (NSPopUpButtonCell *)_colorsPopup.cell;
    cell.arrowPosition = NSPopUpNoArrow;
    cell = (NSPopUpButtonCell *)_filterByPopup.cell;
    cell.arrowPosition = NSPopUpNoArrow;
    [_filterByPopup setBezelStyle:NSBezelStyleRegularSquare];
    [_colorsPopup setBezelStyle:NSBezelStyleRegularSquare];
    [_filterByPopup setButtonType:NSButtonTypeMomentaryLight];
    [_colorsPopup setButtonType:NSButtonTypeMomentaryLight];
    [_regexButton setBezelStyle:NSBezelStyleTexturedRounded];
    [_deleteButton setBezelStyle:NSBezelStyleTexturedRounded];
  
    [Filter.filterPopupInfos enumerateObjectsUsingBlock:^(FilterTypePopupInfo* info, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:info.name action:nil keyEquivalent:@""];
        menuItem.tag = idx;
        [_filterByPopup.menu addItem:menuItem];
    }];
    
    [Filter.colorPopupInfos
     enumerateObjectsUsingBlock:^(FilterColorPopupInfo* info, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:info.name action:nil keyEquivalent:@""];
        menuItem.image = [self swatchForColor:info.color];
        menuItem.tag = idx;
        [_colorsPopup.menu addItem:menuItem];
    }];
    
    [_filterByText setTarget:self];
    [_filterByText setAction:@selector(filterTextChanged:)];
}

- (IBAction)deleteButtonPressed:(id)sender {
    _onDelete();
}

- (IBAction)regexButtonPressed:(id)sender {
    _onRegexToggled();
}

- (IBAction)enableToggled:(NSButton *)sender {
    _filter.isEnabled = sender.state == NSControlStateValueOn;
    [_filterByText setEnabled:_filter.isEnabled];
    [_filtersButton setEnabled:true];
    _onFilterChanged(_filter);
}

- (IBAction)filterByChanged:(NSPopUpButton *)sender {
    _filter.type = sender.selectedTag;
    _onFilterChanged(_filter);
}

- (IBAction)colorChanged:(NSPopUpButton *)sender {
    _filter.colorTag = sender.selectedTag;
    _onFilterChanged(_filter);
}

- (void)filterTextChanged:(NSTextField *)sender {
    if (![_filter.text isEqualToString:sender.stringValue]) {
        BOOL isSenderEmpty = [sender.stringValue isEqualToString:@""];
        [_isEnabledToggle setState: isSenderEmpty ? NSControlStateValueOff : NSControlStateValueOn];
        [self enableToggled:_isEnabledToggle];

        _filter.text = sender.stringValue;
        _onFilterChanged(_filter);
    }
    
  [_filtersButton setEnabled:true];
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
    self.regexButton.state = filter.isRegex ? NSControlStateValueOn : NSControlStateValueOff;
    [_filterByText setEnabled:filter.isEnabled];
    [_filtersButton setEnabled:true];
    [self.colorsPopup selectItemWithTag:filter.colorTag];
    [self.filterByPopup selectItemWithTag:filter.type];
  
    _filter = filter;
}

- (IBAction)filterPressed:(id)sender {
    [_filtersButton setEnabled:false];
    [_filterByText setEnabled:true];
    [_filterByText becomeFirstResponder];
}

@end

