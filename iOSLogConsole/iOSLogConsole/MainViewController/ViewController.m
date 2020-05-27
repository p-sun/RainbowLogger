//
//  ViewController.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "ViewController.h"
#import "NSColorExtensions.h"
#import "Filter.h"

@implementation ViewController

- (void)awakeFromNib {
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor NSColorFrom255Red:46.0 green:44.0 blue:54.0 alpha:1.0].CGColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _filtersManager = [[FiltersManager alloc] init];
    [_filtersManager setDelegate: self];
    
    _logsManager = [[LogsManager alloc] init];
    [_logsManager setDelegate:self];
    
    [self.filtersTableView setFiltersDelegate:self];
    
    [self.logsTableView setupTable];
    [self.filtersTableView setupTable];

    [self startFileReader];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self waitForLogs];
}

- (void)addFilterOnTextFieldEnter:(NSTextField *)sender {
    Filter *filter = [[Filter alloc] initWithType:FilterByTypeContainsOneOrMoreOf
                                             text:sender.stringValue
                                         colorTag:1
                                        isEnabled:YES];
    [_filtersManager addFilter:filter];

    sender.stringValue = @"";
    [_filtersTableView scrollToEndOfDocument:self];
}

#pragma mark - FileReader

- (void)startFileReader {
    self.fileReader = [[FileReader alloc] initWithFilePath:@"bootedSimulator.log"];
    [self.fileReader setDelegate:self];
}

- (void)waitForLogs {
    if (!_hasReadLine) {
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(writeLogsToFileIfNeeded:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(void)writeLogsToFileIfNeeded:(NSTimer *)timer {
    if (!_hasReadLine) {
        system("xcrun simctl spawn booted log stream --level=debug --style=compact > bootedSimulator.log&");
        [self startFileReader];
    }
}

- (void)clearLogs {
    system("rm -f bootedSimulator.log");
}

#pragma mark - FileReaderDelegate

-(void)fileReaderDidReadLine:(NSString *)line {
    _hasReadLine = YES;
    
    // TODO: Autoscroll is turned on first run
    // Then it turns OFF if users scrolls and lands on a place that's not the bottom
    BOOL autoScroll = _logsTableView.enclosingScrollView.verticalScroller.floatValue == 1 || _logsTableView.enclosingScrollView.verticalScroller.floatValue == 0;
    
    [_logsManager addLog:line passingFilters:_filtersTableView.filters];
    
    if (autoScroll) {
        [_logsTableView scrollToEndOfDocument:nil];
    }
}

#pragma mark - FiltersTableViewDelegate

- (void)didDeleteFilterAtIndex:(NSInteger)index {
    [_filtersManager deleteFilterAtIndex:index];
}

- (void)didChangeFilter:(Filter *)filter atIndex:(NSInteger)index {
    [_filtersManager setFilter:filter atIndex:index];
}

#pragma mark - FilterManagerDelegate

- (void)didChangeFilters:(NSArray<Filter *> *)filters {
    [_filtersTableView setFilters:filters];
    [_logsManager filterLogsBy:filters];
}

#pragma mark - FilteredLogManagerDelegate

- (void)didChangeFilteredLogs:(NSArray<NSString *>*)logs {
    NSLog(@"******** %lu", (long) logs.count);
    [_logsTableView setLines:logs];
}

@end
