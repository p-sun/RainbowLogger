//
//  FiltersTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersTableView.h"
#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, LogsColumnType) {
    LogsColumnTypeFilterBy = 0,
    LogsColumnTypeText = 1,
    LogsColumnTypeIsColor = 2,
    LogsColumnTypeIsEnabled = 3,
    LogsColumnTypeDelete = 4
};

@implementation FiltersTableView

BOOL didSetupTable;
NSArray<NSString *> *columnTitles;
NSInteger numberOfColumns;

- (void)awakeFromNib {
    self.delegate = self;
    self.dataSource = self;
    
    NSNib *textNib = [[NSNib alloc] initWithNibNamed:@"FiltersTextCell" bundle:nil];
    [self registerNib:textNib forIdentifier:@"FiltersTextCell"];
    
    NSNib *logsSwitchNib = [[NSNib alloc] initWithNibNamed:@"FiltersSwitchCell" bundle:nil];
    [self registerNib:logsSwitchNib forIdentifier:@"FiltersSwitchCell"];
}

- (void)setupTable {
    [self setupColumns];
    didSetupTable = YES;
}

- (void)setupColumns {
    columnTitles = @[@"Filter By", @"Text", @"Color", @"Enabled", @"Delete"];
    numberOfColumns = 5;
    
    for (NSString* title in columnTitles) {
        NSTableColumn *column = [[NSTableColumn alloc]initWithIdentifier:title];
        column.title = title;
        [self addTableColumn:column];
    }
}

# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfColumns {
    return didSetupTable ? numberOfColumns : 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 50;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [self makeViewWithIdentifier:@"FiltersTextCell" owner:self];
    
    if ([tableColumn.identifier  isEqual: @"Filter By"]) {
        NSTableCellView *cell = [self makeViewWithIdentifier:@"FiltersSwitchCell" owner:self];
        return cell;
    } else if ([tableColumn.identifier  isEqual: @"TimeColumn"]) {
        cell.textField.stringValue = @"TimeColumn";
    } else if ([tableColumn.identifier  isEqual: @"MessageColumn"]) {
        cell.textField.stringValue = @"MessageColumn";
    }
    return cell;
}

# pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
}


@end
