//
//  ViewController.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "ViewController.h"
#import "NSColorExtensions.h"

@implementation ViewController

- (void)awakeFromNib {
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor NSColorFrom255Red:46.0 green:44.0 blue:54.0 alpha:1.0].CGColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _allLogs = [[NSArray alloc] init];
    
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
    [_filtersTableView addFilterWithText:sender.stringValue];
    sender.stringValue = @"";
    [_filtersTableView scrollToEndOfDocument:self];
}

#pragma mark - Logs

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
    
    [self addLog:line];
    
    if (autoScroll) {
        [_logsTableView scrollToEndOfDocument:nil];
    }
}

#pragma mark - Logs & Filter Management

// Add a log -> Filter just the one log
- (void)addLog:(NSString *)line {
    _allLogs = [_allLogs arrayByAddingObject:line];
    
    if ([self predicateForFilters:_filtersTableView.filters onLog:line]) {
        NSLog(@"*********** add log to %lu", (unsigned long)_logsTableView.lines.count);

        _logsTableView.lines = [_logsTableView.lines arrayByAddingObject:line];
        [_logsTableView reloadData];
    }
}

- (NSArray<NSString *>*)filteredLogsFromAllLogs:(NSArray<Filter *>*)filters {
    NSMutableArray<NSString *> *filtered = [[NSMutableArray alloc] init];
    for (NSString *log in _allLogs) {
        if ([self predicateForFilters:filters onLog:log]) {
            [filtered addObject:log];
        }
    }
    return filtered;
}

- (BOOL)predicateForFilters:(NSArray *)filters onLog:(NSString *)log {
    if (filters.count == 0) {
        return true;
    }
    // Must contain ALL the contains
    
    // Must contain ALL the Regexes
    
    // Must contain >= of ContainsAnyOF
    
    // Must contain NONe of the NOTContains
    
    for (Filter *filter in filters) {
        if (filter.type == FilterByTypeContains) {
            if ([log containsString:filter.text]) {
                return true;
            }
        } else if (filter.type == FilterByTypeNone) {
            if ([log containsString:filter.text]) {
                return false;
            }
        } else if (filter.type == FilterByTypeRegex) {
            // TODO
        } else if (filter.type == FilterByTypeContainsAnyOf) {
            // TODO
        }
    }
    
    return false;
}

#pragma mark - FiltersTableViewDelegate

// Change Filter -> Re-filter all Logs
-(void)didChangeFilters:(NSArray<Filter *>*)filters {
    NSMutableArray<NSString *> *newLines = [[NSMutableArray alloc]
                                            initWithArray:[self filteredLogsFromAllLogs: filters]];
    [_logsTableView setLines:newLines];
    [_logsTableView reloadData];
}

@end
