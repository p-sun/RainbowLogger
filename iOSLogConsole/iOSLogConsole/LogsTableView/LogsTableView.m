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

- (void)setupTable {
    [self setDelegate:self];
    [self setDataSource:self];
    
    NSNib *textNib = [[NSNib alloc] initWithNibNamed:@"FiltersTextCell" bundle:nil];
    [self registerNib:textNib forIdentifier:@"FiltersTextCell"];
    
    _attributedLines = [[NSArray alloc] init];

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

- (void)setAttributedLines:(NSArray<NSAttributedString *> *)attributedLines {
    _attributedLines = attributedLines;
    [self reloadData];
}

# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfColumns {
    return _didSetupTable ? _columnsCount : 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _attributedLines.count;
}

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [self makeViewWithIdentifier:@"FiltersTextCell" owner:self];
    
    if ([tableColumn.identifier  isEqual: @"Message"]) {
        if (row < _attributedLines.count) {
            cell.textField.attributedStringValue = _attributedLines[row];
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
        NSString *line = _attributedLines[row].string;
        NSLog(@"^^^^^^ Copied line: %@", line);
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
        [pasteboard setString:line forType:NSPasteboardTypeString];
    }
}

@end
