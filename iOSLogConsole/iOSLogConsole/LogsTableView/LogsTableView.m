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
    _lines = [[NSMutableArray alloc] init];

    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
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
    return _lines.count;
}

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [self makeViewWithIdentifier:@"FiltersTextCell" owner:self];
    
    if ([tableColumn.identifier  isEqual: @"Message"]) {
        if (row < _lines.count) {
            cell.textField.stringValue = _lines[row];
        }
    } else {
        cell.textField.stringValue = @"Other column";
    }
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.selectedRow;
    if (row != 0) {
        // Copy line to Pasteboard
        NSString *line = _lines[row];
        NSLog(@"^^^^ Copied line: %@", line);
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
        [pasteboard setString:line forType:NSPasteboardTypeString];
    }
}

@end
