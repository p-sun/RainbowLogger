//
//  ViewController.m
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

#import "ViewController.h"
#import "NSColorExtensions.h"
#import "NSViewExtensions.h"
#import "Filter.h"
#import "LogsProcessor.h"

@implementation ViewController {
  NSInteger _previousSelectedRow;
  NSInteger _nextColor;
  BOOL _shouldScrollFiltersTable;
  EditScriptView *_editScriptView;
  dispatch_queue_t _logsProcessingQueue;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Data
  _shouldAutoScroll = _autoscrollButton.state == NSControlStateValueOn;
  _previousSelectedRow = -1;
  _nextColor = 6; // Mint Green
  _shouldScrollFiltersTable = NO;
  
  _filtersManager = [[FiltersManager alloc] init];
  [_filtersManager setDelegate:self];
  
  _scriptRunner = [[ScriptRunner alloc] init];
  [_scriptRunner setDelegate:self];
  
  _logsManager = [[LogsManager alloc] init];
  [_logsManager setDelegate:self];
  
  dispatch_queue_attr_t utilityQOS = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1);
  _logsProcessingQueue = dispatch_queue_create("logsProcessingQueue", utilityQOS);
  
  // Views
  _filtersTableView.allowsMultipleSelection = YES;
  [_filtersTableView setFiltersDelegate:self];
  [_filtersTableView setFilters:[_filtersManager getFilters]];
  
  [_filtersSummaryLabel setAttributedStringValue:[_filtersManager getFiltersSummary]];

  [_logsTextView setScrollDelegate:self];
  
  _editScriptView = [[EditScriptView alloc] initWithFrame: NSMakeRect(0, 0, 88, 88)];
  [_editScriptView setDelegate:self];
  
  [_rightPaneScrollViewContents addSubview:_editScriptView];
  [_editScriptView constrainToSuperview];
  
  [self rightPaneScrollToTop];
  [_rightPane setHidden:YES];
  
  // Start
  [self runScriptPressed:nil];
}

- (void)viewWillAppear {
  [super viewWillAppear];
  
  [_filtersTableView resizeTableWidth];
  [self _updateLogsTable];
}

- (void)viewDidAppear {
  [super viewDidAppear];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(scrollViewDidEndScroll:)
   name:NSScrollViewDidEndLiveScrollNotification
   object:_logsTextView.enclosingScrollView];
}

- (void)viewDidLayout {
  [super viewDidLayout];
}


#pragma mark - IBActions - Top Logs Menu

- (IBAction)runScriptPressed:(id)sender {
  if ([_topMenuRunScriptButton.title isEqualToString:@"Stop Script"]) {
    [self.scriptRunner stopScript];
  } else {
    NSString *script = [EditScriptView loadCustomizedScript];
    [self.scriptRunner runScript:script];
  }
}

- (IBAction)editScriptPressed:(id)sender {
  BOOL shouldHide = ![_verticalSplitView isSubviewCollapsed:_rightPane];
  [_rightPane setHidden:shouldHide];
  if (!shouldHide) {
    [self rightPaneScrollToTop];
  }
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

- (void)rightPaneScrollToTop {
  NSPoint point = NSMakePoint(0.0,
                              [[_rightPanelScrollView documentView] bounds].size.height);
  [_rightPanelScrollView.documentView scrollPoint:point];
}

#pragma mark - EditScriptViewDelegate

-(void)editScriptViewDidPressClose {
  [_rightPane setHidden:YES];
}

-(void)editScriptViewDidPressRunScript {
  [self runScriptPressed:nil];
}

-(void)editScriptViewDidPressAddFiltersForMetro {
  NSArray<Filter* > *filters = @[
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"2022-.*?] " isRegex:YES colorTag:10 replacementText:@"> " isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"******" colorTag:14 isEnabled:NO],
    
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"\\(XPLAT_.{0,1}_Framework\\) " isRegex:YES colorTag:15 replacementText:@"EMPTY" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"(UI_INFRAFramework) " isRegex:NO colorTag:15 replacementText:@"EMPTY" isEnabled:YES],
    
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"[info]" isRegex:NO colorTag:15 replacementText:@"EMPTY" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"[warn]" isRegex:NO colorTag:4 replacementText:@"WARN" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"[error]" isRegex:NO colorTag:3 replacementText:@"ERROR" isEnabled:YES],
    
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"[tid:main]" isRegex:NO colorTag:12 replacementText:@"UI" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"[tid:com.facebook" isRegex:NO colorTag:14 replacementText:@"%" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"%.react.JavaScript]" isRegex:NO colorTag:5 replacementText:@"JS" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"%.react.bridgeless.JavaScript]" isRegex:NO colorTag:4 replacementText:@"VJ" isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"%.react.background]" isRegex:NO colorTag:6 replacementText:@"BG" isEnabled:YES],
    
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"_invoke_2] '" isRegex:NO colorTag:14 replacementText:@"_invoke_2] " isEnabled:YES],
    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"[void RCTStaticInjectionAutoInit()_block_invoke_2]" isRegex:NO colorTag:15 replacementText:@"EMPTY" isEnabled:YES],

    [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"\\[.*?cpp:.*?\\]" isRegex:YES colorTag:9 replacementText:@"CPP" isEnabled:YES],
  ];
  [_filtersManager insertAtBeginningFilters:filters];
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

#pragma mark - ScriptRunnerDelegate

-(void)scriptRunnerDidReadLines:(NSArray<NSString *>*)lines {
  _hasReadLine = YES;
  [_logsManager appendLogs:lines];
}

-(void)scriptRunnerDidUpdateScriptStatus {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self updateRunScriptButton:self->_topMenuRunScriptButton];
    [self updateRunScriptButton:self->_editScriptView.runScriptButton];
  });
}

-(void)updateRunScriptButton:(NSButton *)button {
  if ([self.scriptRunner isScriptRunning]) {
    [button setTitle:@"Stop Script"];
    if (@available(macOS 11.0, *)) {
      [button setImage:[NSImage imageWithSystemSymbolName:@"stop.fill" accessibilityDescription:nil]];
    }
  } else {
    [button setTitle:@" Run Script"];
    if (@available(macOS 11.0, *)) {
      [button setImage:[NSImage imageWithSystemSymbolName:@"play.fill" accessibilityDescription:nil]];
    }
  }
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

-(void)filtersDidUpdate:(NSArray<Filter *>*)filters {
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
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(_logsProcessingQueue, ^{
      __strong __typeof(weakSelf) strongSelf = weakSelf;
      if (!strongSelf) {
        return;
      }
      
      NSAttributedString *lines = [LogsProcessor coloredLinesFromLogs:logs filteredBy:[strongSelf->_filtersManager getFilters]];
      [strongSelf->_logsTextView addAttributedLines:lines shouldAutoscroll:strongSelf->_shouldAutoScroll];
    });
  }
}

- (void)didChangeLogs:(NSArray<Log *>*)logs {
  if (!_isPaused) {
    [self _updateLogsTable];
  }
}

- (void)_updateLogsTable {
  __weak __typeof__(self) weakSelf = self;
  dispatch_async(_logsProcessingQueue, ^{
    __strong __typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    
    NSAttributedString *lines = [LogsProcessor coloredLinesFromLogs:strongSelf->_logsManager.getLogs filteredBy:[strongSelf->_filtersManager getFilters]];
    [strongSelf->_logsTextView setAttributedLines:lines shouldAutoscroll:strongSelf->_shouldAutoScroll];
  });
  
  NSAttributedString *newSummary = [_filtersManager getFiltersSummary];
  dispatch_async(dispatch_get_main_queue(), ^{
    __strong __typeof__(self) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }

    [strongSelf->_filtersSummaryLabel setHidden:[newSummary length] == 0];
    [strongSelf->_filtersSummaryLabel setAttributedStringValue:newSummary];
  });
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
