//
//  FilterCell.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface FilterCell : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *filterByPopup;
@property (weak) IBOutlet NSTextField *filterByText;
@property (weak) IBOutlet NSPopUpButton *colorsPopup;
@property (weak) IBOutlet NSButton *isEnabledToggle;

@property (nonatomic, strong) Filter *filter;

@end

NS_ASSUME_NONNULL_END
