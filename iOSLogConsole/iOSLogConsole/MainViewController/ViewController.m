//
//  ViewController.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

#import "ViewController.h"
#import "NSColorExtensions.h"
#import "Filter.h"
#import "LogsProcessor.h"

@implementation ViewController {
  NSInteger _previousSelectedRow;
  NSInteger _nextColor;
  BOOL _shouldScrollFiltersTable;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Data
  _shouldAutoScroll = _autoscrollButton.state == NSControlStateValueOn;
  _previousSelectedRow = -1;
  _nextColor = 6; // Mint Green
  _shouldScrollFiltersTable = NO;
  
  [self setupCustomizeScriptTextView];
  
  _filtersManager = [[FiltersManager alloc] init];
  [_filtersManager setDelegate:self];
  
  _fileReader = [[FileReader alloc] init];
  [_fileReader setDelegate:self];
  
  _logsManager = [[LogsManager alloc] init];
  [_logsManager setDelegate:self];
  
  // Views
  _filtersTableView.allowsMultipleSelection = YES;
  [_filtersTableView setFiltersDelegate:self];
  [_filtersTableView setFilters:[_filtersManager getFilters]];
  
  [_logsTextView setScrollDelegate:self];
  
  [_rightPanel setHidden:YES];

  _customizeScriptTextView.delegate = self;
}

- (void)viewWillAppear {
  [super viewWillAppear];
  [_filtersTableView resizeTableWidth];
}

- (void)viewDidAppear {
  [super viewDidAppear];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(scrollViewDidEndScroll:)
   name:NSScrollViewDidEndLiveScrollNotification
   object:_logsTextView.enclosingScrollView];
}

#pragma mark - IBActions - Top Logs Menu

- (IBAction)attachLoggerPressed:(id)sender {
  [self.fileReader reattachToSimulator];
}

- (IBAction)editAttachScriptPressed:(id)sender {
  BOOL shouldHide = ![_verticalSplitView isSubviewCollapsed:_rightPanel];
  [_rightPanel setHidden:shouldHide];
}

- (IBAction)clearLogs:(id)sender {
  [_logsManager clearLogs];
  [self _updateLogsTable];
}

- (IBAction)pauseButtonToggled:(NSButton *)sender {
  _isPaused = sender.state == NSControlStateValueOn;
  if (!_isPaused) {
    [self setAutoscrollState:true];
    [self _updateLogsTable];
  }
}

- (IBAction)autoscrollButtonToggled:(NSButton *)sender {
  _shouldAutoScroll = sender.state == NSControlStateValueOn;
}

#pragma mark - IBActions - Bottom Filters Menu

- (IBAction)addFilterButtonPressed:(id)sender {
  [self addFilterOnTextFieldEnter:_addFilterTextField];
}

- (void)addFilterOnTextFieldEnter:(NSTextField *)sender {
  Filter *filter = [[Filter alloc] initWithCondition:FilterConditionColorContainingText
                                                text:sender.stringValue
                                            colorTag:_nextColor
                                           isEnabled:YES];
  // Calculate next color
  NSInteger minColor = 1; // Smaller index of next color
  NSInteger maxColor = 13; // Largest index of next color
  _nextColor = MAX((_nextColor + 1) % (maxColor + 1), minColor);
  
  // Reset text field to empty
  sender.stringValue = @"";
  
  // Add filter
  _previousSelectedRow = _filtersTableView.numberOfRows;
  _shouldScrollFiltersTable = YES;
  [_filtersManager appendFilter:filter];
}

- (IBAction)deleteSelectedFilter:(id)sender {
  NSIndexSet *selectedRows = _filtersTableView.selectedRowIndexes;
  if (selectedRows.count >= 0) {
    _previousSelectedRow = selectedRows.firstIndex;
    [_filtersManager deleteFiltersAtIndexes:selectedRows];
  }
}

#pragma mark - IBActions - Customize Script Right Panel
// TODO Refactor script logic out of ViewController

- (IBAction)customizeCancelPressed:(id)sender {
  NSString *script = [self loadCustomizedScript];
  if (script) {
    _customizeScriptTextView.string = script;
  }
}

- (IBAction)customizeDefaultPressed:(id)sender {
  NSString *defaultScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --predicate '(NOT (subsystem contains \"com.apple\"))'";
  _customizeScriptTextView.string = defaultScript;
  [self saveCustomizedScript:defaultScript];
}

- (IBAction)customizeApplyPressed:(id)sender {
  [self saveCustomizedScript:_customizeScriptTextView.string];
}

- (IBAction)customizeClosePanelPressed:(id)sender {
  [self customizeCancelPressed:nil];
  [_rightPanel setHidden:YES];
}

- (void)setupCustomizeScriptTextView {
  //   ----------------------------------------------------------
  //   Override the saved script for the "Attach Logger" button
  //   ----------------------------------------------------------
  
  //   --- Script for getting device logs ---
//     NSString *newScript = @"idevicesyslog -p Facebook -m \"****\"";
  
  //   --- My preferred log for getting logs from simulator ---
  //   Really close to Flipper's logs. Still shows some Network and Security logs though.
  //   Test command in terminal by removing the \ escape before the quotes.
     NSString *newScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --process=Facebook --predicate '(NOT (subsystem contains \"com.apple\")) AND eventMessage contains \"****\"\'";

  //   --- For testing new start ---
//       NSString *newScript = nil;
  
  // --- Save script ---
    [self saveCustomizedScript:newScript];
  //   ----------------------------------------------------------
  
  NSString *script = [self loadCustomizedScript];
  if (script == nil) {
    [self customizeDefaultPressed:nil];
  } else if (![script isEqualToString:_customizeScriptTextView.string]) {
    _customizeScriptTextView.string = script;
  }
  
  [self updateCustomizeScriptApplyButtonEnabled];
}
  
- (void)saveCustomizedScript:(NSString*)newScript {
  [[NSUserDefaults standardUserDefaults] setValue:newScript forKey:@"UserDefaultsKeyCustomizedScript"];
  [self updateCustomizeScriptApplyButtonEnabled];
}

- (NSString*)loadCustomizedScript {
  return [[NSUserDefaults standardUserDefaults] valueForKey:@"UserDefaultsKeyCustomizedScript"];
}

- (void)updateCustomizeScriptApplyButtonEnabled {
  NSString *oldScript = [self loadCustomizedScript];
  NSString *newScript = _customizeScriptTextView.string;
  BOOL didTextChange = ![oldScript isEqualToString:newScript];
  [_customizeScriptApplyButton setEnabled:didTextChange];
  [_customizeScriptCancelChangesButton setEnabled:didTextChange];
  NSLog(@"****");
}

#pragma mark - NSTextViewDelegate for the Customize panel
// TODO Refactor it out of ViewController
- (void)textDidChange:(NSNotification *)notification {
  NSTextView *textView = notification.object;
  if (textView == _customizeScriptTextView) {
    [self updateCustomizeScriptApplyButtonEnabled];
  }
}

#pragma mark - FileReaderDelegate

-(void)fileReaderDidReadLines:(NSArray<NSString *>*)lines {
  _hasReadLine = YES;
  [_logsManager appendLogs:lines];
}

#pragma mark - Autoscroll

- (void)logsScrollViewDidScrollUp {
  [self setAutoscrollState:NO];
}

- (void)logsScrollViewDidScrollDown {
  BOOL shouldAutoScroll = _logsTextView.enclosingScrollView.verticalScroller.floatValue == 1;
  [self setAutoscrollState:shouldAutoScroll];
}

- (void)scrollViewDidEndScroll:(NSNotification *)aNotification {
  // When the user drags the scrollwheel to the bottom, set autoscroll on
  if (aNotification.object == _logsTextView.enclosingScrollView) {
    [self logsScrollViewDidScrollDown];
  }
}

- (void)setAutoscrollState:(BOOL)autoScroll {
  _shouldAutoScroll = autoScroll;
  _autoscrollButton.state = autoScroll ? NSControlStateValueOn : NSControlStateValueOff;
}

#pragma mark - FiltersManagerDelegate

-(void)filtersDidUpdate: (NSArray<Filter *>*) filters {
  [_filtersTableView setFilters:filters];
  dispatch_async(dispatch_get_main_queue(), ^{
    // Update Filters Table
    [self->_filtersTableView reloadData];
    [self->_filtersTableView resizeTableWidth];
    [self selectNextRow];
    
    if (self->_shouldScrollFiltersTable) {
      self->_shouldScrollFiltersTable = NO;
      [self->_filtersTableView scrollToEndOfDocument:nil];
    }
    
    // Update Logs Table
    [self _updateLogsTable];
  });
}

#pragma mark - FiltersTableViewDelegate

- (void)didToggleRegexAtIndex:(NSInteger)index {
  [_filtersManager toggleRegexForFilterAtIndex:index];
}

- (void)didDeleteFilterAtIndexes:(NSIndexSet *)indexes {
  [self deleteSelectedFilter:nil];
}

- (void)didChangeFilter:(Filter *)filter atIndex:(NSInteger)index {
  [_filtersManager changeFilter:filter atIndex:index];
  // Since Filter is mutable, there's no need to call filtersDidUpdate to refresh the table
  [self _updateLogsTable];
}

- (void)didMoveFilter:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  [_filtersManager moveFilterFromIndex:fromIndex toIndex:toIndex];
}

#pragma mark - LogsManagerDelegate

- (void)didAppendLogs:(NSArray<Log *>*)logs {
  if (!_isPaused) {
    NSAttributedString *lines = [LogsProcessor coloredLinesFromLogs:logs filteredBy:[_filtersManager getFilters]];
    [_logsTextView addAttributedLines:lines shouldAutoscroll:_shouldAutoScroll];
  }
}

- (void)didChangeLogs:(NSArray<Log *>*)logs {
  if (!_isPaused) {
    [self _updateLogsTable];
  }
}

- (void)_updateLogsTable {
  NSAttributedString *lines = [LogsProcessor coloredLinesFromLogs:_logsManager.getLogs filteredBy:[_filtersManager getFilters]];
  [_logsTextView setAttributedLines:lines shouldAutoscroll:_shouldAutoScroll];
}

#pragma mark - Select Next Row After Deleting a Row

- (void)selectNextRow {
  if (_previousSelectedRow >= 0 && _filtersTableView.numberOfRows > 0) {
    if (_previousSelectedRow < _filtersTableView.numberOfRows) {
      [self->_filtersTableView selectRowIndexes:
       [NSIndexSet indexSetWithIndex:_previousSelectedRow] byExtendingSelection:false];
    } else {
      [self->_filtersTableView selectRowIndexes:
       [NSIndexSet indexSetWithIndex:_filtersTableView.numberOfRows - 1] byExtendingSelection:false];
    }
    _previousSelectedRow = -1;
  }
}

@end
