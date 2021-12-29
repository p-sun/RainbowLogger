//
//  FiltersTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersTableView.h"
#import "FilterCell.h"

typedef NS_ENUM(NSInteger, LogsColumnType) {
    LogsColumnTypeFilterBy = 0,
    LogsColumnTypeText = 1,
    LogsColumnTypeIsColor = 2,
    LogsColumnTypeIsEnabled = 3,
    LogsColumnTypeDelete = 4
};

@implementation FiltersTableView {
    BOOL _didSetupTable;
    NSInteger _columnsCount;
    NSArray<NSString *> *_columnTitles;
    NSArray *_filters;
    NSInteger _sourceDragRow;
}

# pragma mark - Setup

- (void)awakeFromNib {
    self.delegate = self;
    self.dataSource = self;

    if (_filters == nil) {
        _filters = [[NSArray alloc] init];
    }
    
    NSNib *textNib = [[NSNib alloc] initWithNibNamed:@"FilterCell" bundle:nil];
    [self registerNib:textNib forIdentifier:@"FilterCell"];
  
    self.verticalMotionCanBeginDrag = YES;
    [self registerForDraggedTypes:@[NSPasteboardTypeString]];
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

- (void)setFilters:(NSArray<Filter *>*)filters {
    if (![_filters isEqualToArray:filters]) {
        _filters = filters;
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadData];
        });
    }
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
            [weakSelf.filtersDelegate didDeleteFilterAtIndex:row];
        };
        cell.onRegexToggled = ^{
            [weakSelf.filtersDelegate didToggleRegexAtIndex:row];
        };
        cell.onFilterChanged = ^(Filter* filter) {
            [weakSelf.filtersDelegate didChangeFilter:filter atIndex:row];
        };
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

# pragma mark - Dragging

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
  NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
  [item setString:@"string" forType:NSPasteboardTypeString];
  _sourceDragRow = row;
  return item;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
  return dropOperation == NSTableViewDropAbove ? NSDragOperationMove : NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
  NSPasteboardItem *item = info.draggingPasteboard.pasteboardItems.firstObject;
  if (item == NULL) {
    return NO;
  }
  
  [self.filtersDelegate didMoveFilter:_sourceDragRow toIndex:row];
  
  return true;
}

@end
