//
//  FiltersTableView.m
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersTableView.h"
#import "FilterCell.h"
#include <pthread.h>

@implementation FiltersTableView {
  NSInteger _columnsCount;
  NSArray<NSString *> *_columnTitles;
  NSArray *_filters;
  NSInteger _sourceDragRow;
  NSIndexSet *_previousShiftSelection;
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
    [self addTableColumn:column];
  }
  
  // Row Selection
  NSTrackingArea *tracker = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveInActiveApp owner:self userInfo:nil];
  [self addTrackingArea:tracker];
  
  // Header
  [self setHeaderView: nil];
}

- (void)resizeTableWidth {
  CGFloat width = self.window.frame.size.width;
  if (width > 0) {
    self.tableColumns.firstObject.width = width;
  }
}

- (void)setFilters:(NSArray<Filter *>*)filters {
  if (![_filters isEqualToArray:filters]) {
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      __strong __typeof(weakSelf) strongSelf = weakSelf;
      if (!strongSelf) { return; }
      
      strongSelf->_filters = filters;
      [strongSelf reloadData];
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
        
        [strongSelf onFilterSelectedAtRow:row];
      },
    }];
  }
  return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
  return YES;
}

/* Allow multiple selected rows similar to Finder.
   * If Command is pressed, select or deselect current row.
   * If Shift is pressed, add to selection all keys from previous selected row to currently row.
   May be able to avoid this complex logic if it's possible to pass tap event to the NSTableView,
   while allowing a button on the text fields to allow them to become first responder with one tap.
 **/
- (void)onFilterSelectedAtRow:(NSInteger)row {
  NSUInteger flags = [[NSApp currentEvent] modifierFlags];
  if (flags & NSEventModifierFlagCommand) {
    if ([self.selectedRowIndexes containsIndex:row]) {
      [self deselectRow:row];
    } else {
      [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:true];
    }
    _previousShiftSelection = nil;
  } else if (flags & NSEventModifierFlagShift) {
    NSRange rangeToAdd;
    if (self.selectedRow < 0) {
      rangeToAdd = NSMakeRange(0, row + 1);
    } else if (self.selectedRow <= row) {
      rangeToAdd = NSMakeRange(self.selectedRow, row - self.selectedRow + 1);
    } else {
      rangeToAdd = NSMakeRange(row, self.selectedRow - row + 1);
    }
    NSIndexSet *indexesToAdd = [NSIndexSet indexSetWithIndexesInRange:rangeToAdd];

    NSMutableIndexSet *indexesToSelect = [NSMutableIndexSet new];
    [indexesToSelect addIndexes:self.selectedRowIndexes];
    if (_previousShiftSelection) {
      [indexesToSelect removeIndexes:_previousShiftSelection];
      [indexesToSelect addIndexes:indexesToAdd];
    } else {
      [indexesToSelect addIndexes:indexesToAdd];
    }
    [self selectRowIndexes:indexesToSelect byExtendingSelection:false];
    _previousShiftSelection = indexesToAdd;
  } else {
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:false];
    _previousShiftSelection = nil;
  }
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

# pragma mark - Delete Filter with Backspace

- (BOOL)acceptsFirstResponder
{
  return YES;
}

-(void)keyDown:(NSEvent *)event
{
  [super keyDown:event];
  unichar c = NSDeleteCharacter;
  NSString *s = [NSString stringWithCharacters:&c length:1];
  if ([event.charactersIgnoringModifiers isEqual:s]) {
    [self.filtersDelegate didDeleteFilterAtIndexes:self.selectedRowIndexes];
  }
}

@end
