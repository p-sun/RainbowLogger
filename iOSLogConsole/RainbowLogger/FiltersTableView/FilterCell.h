//
//  FilterCell.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

struct FilterCellData {
  Filter *filter;
  NSInteger row;
  
  void(^onRegexToggled)(void);
  void(^onFilterChanged)(Filter *);
  void(^onFilterSelected)(NSInteger row);
};

@interface FilterCell : NSTableCellView

@property (weak) IBOutlet NSButton *isEnabledToggle;
@property (weak) IBOutlet NSPopUpButton *conditionPopup;
@property (weak) IBOutlet NSButton *regexButton;

@property (weak) IBOutlet NSTextField *filterTextField;
@property (weak) IBOutlet NSButton *filtersButton;
@property (weak) IBOutlet NSButton *replaceTextButton;
@property (weak) IBOutlet NSTextField *replaceTextTextField;

@property (weak) IBOutlet NSPopUpButton *colorsPopup;

- (void)setCellData:(struct FilterCellData) data;

- (IBAction)regexButtonPressed:(id)sender;
- (IBAction)enableToggled:(id)sender;
- (IBAction)filterChanged:(id)sender;
- (IBAction)filterPressed:(id)sender;
- (IBAction)replaceFilterPressed:(id)sender;
- (IBAction)colorChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
