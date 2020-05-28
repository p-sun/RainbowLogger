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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _shouldAutoScroll = _autoscrollButton.state == NSControlStateValueOn;
    
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

- (IBAction)addFilterButtonPressed:(id)sender {
    [self addFilterOnTextFieldEnter:_addFilterTextField];
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

- (IBAction)pauseButtonToggled:(NSButton *)sender {
    _isPaused = sender.state == NSControlStateValueOn;
}

- (IBAction)autoscrollButtonToggled:(NSButton *)sender {
    _shouldAutoScroll = sender.state == NSControlStateValueOn;
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
        system("xcrun simctl spawn booted log stream --style=compact > bootedSimulator.log&"); // --process=AppName --level=debug
        [self startFileReader];
    }
}

- (void)clearLogs {
    [_logsManager clearLogs];
}

#pragma mark - FileReaderDelegate

-(void)fileReaderDidReadLine:(NSString *)line {
    _hasReadLine = YES;
    NSString *trimmedString = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    [_logsManager addLog:trimmedString passingFilters:_filtersTableView.filters];
}

#pragma mark - Autoscroll

- (void)logsScrollViewDidScrollUp {
    [self setAutoscrollState:NO];
}

- (void)scrollViewDidEndScroll:(NSNotification *)aNotification {
    if (aNotification.object == _logsTableView.enclosingScrollView) {
        BOOL autoScroll = _logsTableView.enclosingScrollView.verticalScroller.floatValue == 1;
        [self setAutoscrollState:autoScroll];
    }
}

- (void)setAutoscrollState:(BOOL)autoScroll {
    _shouldAutoScroll = autoScroll;
    _autoscrollButton.state = autoScroll ? NSControlStateValueOn : NSControlStateValueOff;
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
    if (!_isPaused) {
        NSArray *attrLogs = [ViewController coloredStringsFromLogs:logs usingFilters:_filtersManager.filters];
        [_logsTableView setAttributedLines:attrLogs shouldAutoscroll:_shouldAutoScroll];
    }
}

#pragma mark - Coloring Logs with Filters

+ (NSArray<NSAttributedString *>*)coloredStringsFromLogs:(NSArray<NSString *>*)logs usingFilters:(NSArray<Filter *>*)filters {
    NSMutableArray<NSAttributedString *>* attrLogs = [[NSMutableArray<NSAttributedString *> alloc] init];
    for (NSString *log in logs) {
        NSAttributedString *coloredLog = [ViewController coloredLog:log usingFilters:filters];
        [attrLogs addObject:coloredLog];
    }
    return attrLogs;
}

+ (NSAttributedString *)coloredLog:(NSString *)log usingFilters:(NSArray<Filter *>*)filters {
    NSError *error = NULL;
    NSMutableAttributedString *coloredString = [[NSMutableAttributedString alloc] initWithString:log];

    for (Filter* filter in filters) {
        if (!filter.isEnabled) {
            continue;
        }
        NSString *regexPattern;
        if (filter.type == FilterByTypeRegex) {
            regexPattern = filter.text;
        } else {
            regexPattern = [NSRegularExpression escapedPatternForString:filter.text];
        }
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexPattern
                                      options:0
                                      error:&error];
        NSRange searchedRange = NSMakeRange(0, [log length]);
        NSArray* matches = [regex matchesInString:log options:0 range: searchedRange];
        for (NSTextCheckingResult *match in matches) {
            FilterColorPopupInfo *info = [Filter colorPopupInfos][filter.colorTag];
            [coloredString addAttributes:@{
                NSForegroundColorAttributeName:info.color,
            } range:match.range];
        }
    }
    
    return coloredString;
}

@end
