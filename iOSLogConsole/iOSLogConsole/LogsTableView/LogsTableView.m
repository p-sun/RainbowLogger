//
//  LogsTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogsTableView.h"

@implementation LogsTableView

- (void)setupTable {
    [self setDelegate:self];
    [self setDataSource:self];
    
    _attributedLines = [[NSArray alloc] init];

    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.tableColumns[0].width = NSScreen.mainScreen.frame.size.width;
    _didSetupTable = YES;
    [self reloadData];
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
    NSTableCellView *view = [self makeViewWithIdentifier:@"LogsCellView" owner:self];
    if (row < _attributedLines.count) {
        [[view textField] setAttributedStringValue:_attributedLines[row]];
    }
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.selectedRow;
    if (row != 0) {
        // Copy line to Pasteboard
        NSString *line = _attributedLines[row].string;
        NSLog(@"^^^^^^ Copied line to pasteboard: %@", line);
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
        [pasteboard setString:line forType:NSPasteboardTypeString];
    }
}

@end
