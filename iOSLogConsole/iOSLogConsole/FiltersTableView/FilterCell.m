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
  
  [_filterTextField setTarget:self];
  [_filterTextField setAction:@selector(filterTextChanged:)];
  
  [_replaceFilterTextField setTarget:self];
  [_replaceFilterTextField setAction:@selector(replaceFilterTextChanged:)];
}

- (IBAction)deleteButtonPressed:(id)sender {
  _onDelete();
}

- (IBAction)regexButtonPressed:(id)sender {
  _onRegexToggled();
}

- (IBAction)enableToggled:(NSButton *)sender {
  _filter.isEnabled = sender.state == NSControlStateValueOn;
  [_filtersButton setEnabled:true];
  [_replaceFiltersButton setEnabled:true];
  _onFilterChanged(_filter);
}

- (IBAction)filterChanged:(NSPopUpButton *)sender {
  _filter.type = sender.selectedTag;
  _onFilterChanged(_filter);
}

- (IBAction)colorChanged:(NSPopUpButton *)sender {
  _filter.colorTag = sender.selectedTag;
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
  self.filterTextField.stringValue = filter.text;
  self.replaceFilterTextField.stringValue = filter.replacementText ? filter.replacementText : @"";
  
  [_filtersButton setEnabled:true];
  [_replaceFiltersButton setEnabled:true];
  self.isEnabledToggle.state = filter.isEnabled ? NSControlStateValueOn : NSControlStateValueOff;
  self.regexButton.state = filter.isRegex ? NSControlStateValueOn : NSControlStateValueOff;

  [self.colorsPopup selectItemWithTag:filter.colorTag];
  [self.filterByPopup selectItemWithTag:filter.type];
  
  _filter = filter;
}

#pragma mark - Filter Text Fields

- (IBAction)filterPressed:(id)sender {
  [_filtersButton setEnabled:false];
  [_filterTextField becomeFirstResponder];
}

- (IBAction)replaceFilterPressed:(id)sender {
  [_replaceFiltersButton setEnabled:false];
  [_replaceFilterTextField becomeFirstResponder];
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

- (void)replaceFilterTextChanged:(NSTextField *)sender {
  if (![_filter.replacementText isEqualToString:sender.stringValue]) {
    BOOL isSenderEmpty = [sender.stringValue isEqualToString:@""];
    [_isEnabledToggle setState: isSenderEmpty ? NSControlStateValueOff : NSControlStateValueOn];
    [self enableToggled:_isEnabledToggle];
    
    _filter.replacementText = sender.stringValue;
    _onFilterChanged(_filter);
  }
  
  [_replaceFiltersButton setEnabled:true];
}
@end

