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
  NSInteger _columnsCount;
  NSArray<NSString *> *_columnTitles;
  NSArray *_filters;
  NSInteger _sourceDragRow;
  NSInteger _selectedRow;
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
  
  if (self.tableColumns.count == 0) {
    NSTableColumn *column = [[NSTableColumn alloc]initWithIdentifier:@"titleColumn"];
    column.title = @"Filters";
    [self addTableColumn:column];
  }
  
  // Row Selection
  NSTrackingArea *tracker = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveInActiveApp owner:self userInfo:nil];
  [self addTrackingArea:tracker];
  _selectedRow = -1;
}

- (void)resizeTableWidth {
  CGFloat width = self.window.frame.size.width;
  if (width > 0) {
    self.tableColumns.firstObject.width = width;
  }
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return _filters.count;
}

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  
  FilterCell *cell = (FilterCell *)[self makeViewWithIdentifier:@"FilterCell" owner:self];
  if (row < _filters.count) {
    __weak __typeof__(self) weakSelf = self;
    [cell setCellData:(struct FilterCellData) {
      .filter = _filters[row],
      .row = row,
      .onDelete = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf.filtersDelegate didDeleteFilterAtIndex:row];
      },
      .onRegexToggled = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf.filtersDelegate didToggleRegexAtIndex:row];
      },
      .onFilterChanged = ^(Filter* filter) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [strongSelf.filtersDelegate didChangeFilter:filter atIndex:row];
      },
      .onFilterSelected = ^(NSInteger row) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        strongSelf->_selectedRow = row;
        [strongSelf selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:false];
      },
    }];
  }
  return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
  return YES;
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
