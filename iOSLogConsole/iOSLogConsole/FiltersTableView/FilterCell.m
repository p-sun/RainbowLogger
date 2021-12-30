//
//  FilterCell.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterCell.h"
#import "Filter.h"
#import "NSColorExtensions.h"
#import "FilterColorPopupInfo.h"
#import "FilterConditionPopupInfo.h"

@implementation FilterCell {
  struct FilterCellData _data;
}

- (void)awakeFromNib {
  NSPopUpButtonCell *cell = (NSPopUpButtonCell *)_colorsPopup.cell;
  cell = (NSPopUpButtonCell *)_conditionPopup.cell;
  
  [FilterConditionPopupInfo.conditionPopupInfos enumerateObjectsUsingBlock:^(FilterConditionPopupInfo* info, NSUInteger idx, BOOL * _Nonnull stop) {
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:info.name action:nil keyEquivalent:@""];
    menuItem.tag = idx;
    [_conditionPopup.menu addItem:menuItem];
  }];
  
  [FilterColorPopupInfo.colorPopupInfos
   enumerateObjectsUsingBlock:^(FilterColorPopupInfo* info, NSUInteger idx, BOOL * _Nonnull stop) {
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:info.name action:nil keyEquivalent:@""];
    menuItem.image = [self swatchForColor:info.color];
    menuItem.tag = idx;
    [_colorsPopup.menu addItem:menuItem];
  }];
  
  [_filterTextField setTarget:self];
  [_filterTextField setAction:@selector(filterTextChanged:)];
  
  [_replaceTextTextField setTarget:self];
  [_replaceTextTextField setAction:@selector(replaceFilterTextChanged:)];  
}

- (IBAction)regexButtonPressed:(id)sender {
  _data.onRegexToggled();
}

- (IBAction)enableToggled:(NSButton *)sender {
  _data.filter.isEnabled = sender.state == NSControlStateValueOn;
  [_filtersButton setEnabled:true];
  [_replaceTextButton setEnabled:true];
  _data.onFilterChanged(_data.filter);
}

- (IBAction)filterChanged:(NSPopUpButton *)sender {
  _data.filter.condition = sender.selectedTag;
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
  self.replaceTextTextField.stringValue = filter.replacementText ? filter.replacementText : @"";
  
  [_filtersButton setEnabled:true];
  [_replaceTextButton setEnabled:true];
  self.isEnabledToggle.state = filter.isEnabled ? NSControlStateValueOn : NSControlStateValueOff;
  self.regexButton.state = filter.isRegex ? NSControlStateValueOn : NSControlStateValueOff;

  [self.colorsPopup selectItemWithTag:filter.colorTag];
  [self.conditionPopup selectItemWithTag:filter.condition];
  
  _data = data;
}

#pragma mark - Filter Text Fields

- (IBAction)filterPressed:(id)sender {
  [_filtersButton setEnabled:false];
  _data.onFilterSelected(_data.row);
  [_filterTextField becomeFirstResponder];
}

- (IBAction)replaceFilterPressed:(id)sender {
  [_replaceTextButton setEnabled:false];
  _data.onFilterSelected(_data.row);
  [_replaceTextTextField becomeFirstResponder];
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
    
    _data.filter.replacementText = sender.stringValue;
    
    _data.onFilterChanged(_data.filter);
  }
  
  [_replaceTextButton setEnabled:true];
}

@end

