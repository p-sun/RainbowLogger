//
//  FiltersTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersTableView.h"
#import "Filter.h"
#import "FilterCell.h"

typedef NS_ENUM(NSInteger, LogsColumnType) {
    LogsColumnTypeFilterBy = 0,
    LogsColumnTypeText = 1,
    LogsColumnTypeIsColor = 2,
    LogsColumnTypeIsEnabled = 3,
    LogsColumnTypeDelete = 4
};

@implementation FiltersTableView

# pragma mark - Setup

- (void)awakeFromNib {
    self.delegate = self;
    self.dataSource = self;

    if (_filters == nil) {
        _filters = [[NSMutableArray alloc] init];
    }
    
    NSNib *textNib = [[NSNib alloc] initWithNibNamed:@"FilterCell" bundle:nil];
    [self registerNib:textNib forIdentifier:@"FilterCell"];
}

- (void)setupTable {
    [self setupColumns];
    _didSetupTable = YES;
}

- (void)setupColumns {
    _columnTitles = @[@"Filters"];
    _columnsCount = 1;
    
    for (NSString* title in _columnTitles) {
        NSTableColumn *column = [[NSTableColumn alloc]initWithIdentifier:title];
        column.title = title;
        [self addTableColumn:column];
    }
    
    self.tableColumns[0].width = 1200;
}

# pragma mark - Filters

- (void)addFilterWithText:(NSString *)text {
    Filter *filter = [[Filter alloc] initWithText:text];
    [_filters addObject:filter];
    [self reloadData];
}

- (void)deleteFilterAtIndex:(NSInteger)index {
    [_filters removeObjectAtIndex:index];
    [self reloadData];
}

# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfColumns {
    return _didSetupTable ? _columnsCount : 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _filters.count;
}

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    FilterCell *cell = (FilterCell *)[self makeViewWithIdentifier:@"FilterCell" owner:self];
    if (row < _filters.count) {
        __weak __typeof__(self) weakSelf = self;
        [cell setFilter:_filters[row]];
        cell.onDelete = ^{
            [weakSelf deleteFilterAtIndex:row];
        };
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

@end
