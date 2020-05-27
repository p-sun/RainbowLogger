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
    
    [_logsTableView setupTable];

    [_logsScrollView setScrollDelegate:self];

    [_filtersTableView setFiltersDelegate:self];
    [_filtersTableView setupTable];

    [self startFileReader];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self waitForLogs];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndScroll:) name:NSScrollViewDidEndLiveScrollNotification object:_logsScrollView];
}

- (IBAction)trashPressed:(id)sender {
    [self clearLogs];
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

// If we waited 2 seconds bootedSimulator.log doesn't update, create a new process to tail logs to file
// TODO clean up process when app is killed
-(void)writeLogsToFileIfNeeded:(NSTimer *)timer {
    if (!_hasReadLine) {
        system("rm -f bootedSimulator.log");
        system("killall log");
        system("xcrun simctl spawn booted log stream --level=debug --style=compact > bootedSimulator.log&");
        [self startFileReader];
    }
}

- (void)clearLogs {
    [_logsManager clearLogs];
}

#pragma mark - FileReaderDelegate

-(void)fileReaderDidReadLine:(NSString *)line {
    _hasReadLine = YES;
    [_logsManager addLog:line passingFilters:_filtersTableView.filters];

    if (_autoscrollButton.state == NSControlStateValueOn) {
        [_logsTableView scrollToEndOfDocument:nil];
    }
}

#pragma mark - Autoscroll

- (void)logsScrollViewDidScrollUp {
    _autoscrollButton.state = NSControlStateValueOff;
}

- (void)scrollViewDidEndScroll:(NSNotification *)aNotification {
    if (aNotification.object == _logsTableView.enclosingScrollView) {
        BOOL autoScroll = _logsTableView.enclosingScrollView.verticalScroller.floatValue == 1;
        _autoscrollButton.state = autoScroll ? NSControlStateValueOn : NSControlStateValueOff;
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
    // NSLog(@"******** %lu", (long) logs.count);
    if (_pauseButton.state != NSControlStateValueOn) {
        [_logsTableView setLines:logs];
    }
}

@end
