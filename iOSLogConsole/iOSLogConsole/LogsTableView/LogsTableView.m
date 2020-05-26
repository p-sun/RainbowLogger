//
//  LogsTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsTableView.h"
#import <Cocoa/Cocoa.h>

@implementation LogsTableView

- (void)awakeFromNib {
    [self setDelegate:self];
    [self setDataSource:self];

    NSNib *textNib = [[NSNib alloc] initWithNibNamed:@"FiltersTextCell" bundle:nil];
    [self registerNib:textNib forIdentifier:@"FiltersTextCell"];
}

- (void)setupTable {
//    [self setRowHeight:24];
    [self setupColumns];
    _didSetupTable = YES;
    [self reloadData];
}

- (void)setupColumns {
    _columnTitles = @[@"Message"];
    _columnsCount = 1;

    for (NSString* title in _columnTitles) {
        NSTableColumn *column = [[NSTableColumn alloc]initWithIdentifier:title];

        column.title = title;
        [self addTableColumn:column];
    }
    
    self.tableColumns[0].width = NSScreen.mainScreen.frame.size.width;
}

# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfColumns {
    return _didSetupTable ? _columnsCount : 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 50;
}

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [self makeViewWithIdentifier:@"FiltersTextCell" owner:self];

    if ([tableColumn.identifier  isEqual: @"Message"]) {
        cell.textField.stringValue = @"MessageColumn MessageColumn MessageColumn MessageColumn";
    } else {
        cell.textField.stringValue = @"Other column";
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

@end
