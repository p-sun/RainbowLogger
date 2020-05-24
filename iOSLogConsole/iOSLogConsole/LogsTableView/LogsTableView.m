//
//  LogsTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsTableView.h"

@implementation LogsTableView

- (void)awakeFromNib {
    self.delegate = self;
    self.dataSource = self;
    NSNib *textNib = [[NSNib alloc] initWithNibNamed:@"LogsTextCell" bundle:nil];
    [self registerNib:textNib forIdentifier:@"LogsTextCell"];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 50;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [self makeViewWithIdentifier:@"LogsTextCell" owner:self];
    
    if ([tableColumn.identifier  isEqual: @"ProcessColumn"]) {
        cell.textField.stringValue = @"ProcessColumn";
    } else if ([tableColumn.identifier  isEqual: @"TimeColumn"]) {
        cell.textField.stringValue = @"TimeColumn";
    } else if ([tableColumn.identifier  isEqual: @"MessageColumn"]) {
        cell.textField.stringValue = @"MessageColumn";
    }
    return cell;
}

@end
