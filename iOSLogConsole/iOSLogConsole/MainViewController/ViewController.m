//
//  ViewController.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "NSColorExtensions.h"
#import "Filter.h"
#import "LogsProcessor.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _shouldAutoScroll = _autoscrollButton.state == NSControlStateValueOn;
    
    _filtersManager = [[FiltersManager alloc] init];
    [_filtersTableView setFilters:_filtersManager.filters];

    _logsManager = [[LogsManager alloc] init];
    [_logsManager setDelegate:self];
    [_logsTextView setScrollDelegate:self];
    
    [_filtersTableView setFiltersDelegate:self];
    [_filtersTableView setupTable];
    
    self.fileReader = [[FileReader alloc] init];
    [self.fileReader setDelegate:self];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(scrollViewDidEndScroll:)
     name:NSScrollViewDidEndLiveScrollNotification
     object:_logsTextView.enclosingScrollView];
}

- (IBAction)clearLogs:(id)sender {
    [_logsManager clearLogs];
    [self _filterAllLogsAndUpdateTextView];
}

- (IBAction)clearFilters:(id)sender {
    [_filtersManager clearFilters];
    [_filtersTableView setFilters:_filtersManager.filters];
    [self _filterAllLogsAndUpdateTextView];
}

- (IBAction)addFilterButtonPressed:(id)sender {
    [self addFilterOnTextFieldEnter:_addFilterTextField];
}

- (void)addFilterOnTextFieldEnter:(NSTextField *)sender {
    Filter *filter = [[Filter alloc] initWithType:FilterByTypeContainsOneOrMoreOf
                                             text:sender.stringValue
                                         colorTag:1
                                        isEnabled:YES];
    sender.stringValue = @"";
    
    [_filtersManager appendFilter:filter];
    [_filtersTableView setFilters:_filtersManager.filters];
    [_filtersTableView scrollToEndOfDocument:self];
    
    [self _filterAllLogsAndUpdateTextView];
}

- (IBAction)pauseButtonToggled:(NSButton *)sender {
    _isPaused = sender.state == NSControlStateValueOn;
    if (!_isPaused) {
        [self setAutoscrollState:true];
        [self _filterAllLogsAndUpdateTextView];
    }
}

- (IBAction)autoscrollButtonToggled:(NSButton *)sender {
    _shouldAutoScroll = sender.state == NSControlStateValueOn;
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

#pragma mark - FiltersTableViewDelegate

- (void)didDeleteFilterAtIndex:(NSInteger)index {
    [_filtersManager deleteFilterAtIndex:index];
    [_filtersTableView setFilters:_filtersManager.filters];
    [self _filterAllLogsAndUpdateTextView];
}

- (void)didChangeFilter:(Filter *)filter atIndex:(NSInteger)index {
    [_filtersManager replaceFilter:filter atIndex:index];
    [self _filterAllLogsAndUpdateTextView];
}

#pragma mark - LogsManagerDelegate
- (void)didAppendLogs:(NSArray<Log *>*)logs {
    if (!_isPaused) {
        NSAttributedString *lines = [LogsProcessor coloredLinesFromLogs:logs filteredBy:_filtersManager.filters];
        [_logsTextView addAttributedLines:lines shouldAutoscroll:_shouldAutoScroll];
    }
}

- (void)didChangeLogs:(NSArray<Log *>*)logs {
    if (!_isPaused) {
        [self _filterAllLogsAndUpdateTextView];
    }
}

- (void)_filterAllLogsAndUpdateTextView {
    NSAttributedString *lines = [LogsProcessor coloredLinesFromLogs:_logsManager.getLogs filteredBy:_filtersManager.filters];
    [_logsTextView setAttributedLines:lines shouldAutoscroll:_shouldAutoScroll];
}

@end
