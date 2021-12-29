//
//  FilterCell.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterCell.h"
#import "Filter.h"

@implementation FilterCell {
  struct FilterCellData _data;
}

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

- (IBAction)regexButtonPressed:(id)sender {
  _data.onRegexToggled();
}

- (IBAction)enableToggled:(NSButton *)sender {
  _data.filter.isEnabled = sender.state == NSControlStateValueOn;
  [_filtersButton setEnabled:true];
  [_replaceFiltersButton setEnabled:true];
  _data.onFilterChanged(_data.filter);
}

- (IBAction)filterChanged:(NSPopUpButton *)sender {
  _data.filter.type = sender.selectedTag;
  _data.onFilterChanged(_data.filter);
}

- (IBAction)colorChanged:(NSPopUpButton *)sender {
  _data.filter.colorTag = sender.selectedTag;
  _data.onFilterChanged(_data.filter);
}

- (NSImage *)swatchForColor:(NSColor *)color {
  NSSize size = NSMakeSize(12, 12);
  NSImage *image = [[NSImage alloc] initWithSize:size];
  [image lockFocus];
  [color drawSwatchInRect:NSMakeRect(0, 0, size.width, size.height)];
  [image unlockFocus];
  return image;
}

- (void)setCellData:(struct FilterCellData) data {
  Filter *filter = data.filter;
  
  self.filterTextField.stringValue = filter.text;
  self.replaceFilterTextField.stringValue = filter.replacementText ? filter.replacementText : @"";
  
  [_filtersButton setEnabled:true];
  [_replaceFiltersButton setEnabled:true];
  self.isEnabledToggle.state = filter.isEnabled ? NSControlStateValueOn : NSControlStateValueOff;
  self.regexButton.state = filter.isRegex ? NSControlStateValueOn : NSControlStateValueOff;

  [self.colorsPopup selectItemWithTag:filter.colorTag];
  [self.filterByPopup selectItemWithTag:filter.type];
  
  _data = data;
}

#pragma mark - Filter Text Fields

- (IBAction)filterPressed:(id)sender {
  [_filtersButton setEnabled:false];
  [_filterTextField becomeFirstResponder];
  _data.onFilterSelected(_data.row);
}

- (IBAction)replaceFilterPressed:(id)sender {
  [_replaceFiltersButton setEnabled:false];
  [_replaceFilterTextField becomeFirstResponder];
  _data.onFilterSelected(_data.row);
}

- (void)filterTextChanged:(NSTextField *)sender {
  if (![_data.filter.text isEqualToString:sender.stringValue]) {
    BOOL isSenderEmpty = [sender.stringValue isEqualToString:@""];
    [_isEnabledToggle setState: isSenderEmpty ? NSControlStateValueOff : NSControlStateValueOn];
    [self enableToggled:_isEnabledToggle];
    
    _data.filter.text = sender.stringValue;
    
    _data.onFilterChanged(_data.filter);
  }
  
  [_filtersButton setEnabled:true];
}

- (void)replaceFilterTextChanged:(NSTextField *)sender {
  if (![_data.filter.replacementText isEqualToString:sender.stringValue]) {
    BOOL isSenderEmpty = [sender.stringValue isEqualToString:@""];
    [_isEnabledToggle setState: isSenderEmpty ? NSControlStateValueOff : NSControlStateValueOn];
    [self enableToggled:_isEnabledToggle];
    
    _data.filter.replacementText = sender.stringValue;
    
    _data.onFilterChanged(_data.filter);
  }
  
  [_replaceFiltersButton setEnabled:true];
}

@end

