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

    [self.logsTableView setupTable];
    [self.filtersTableView setupTable];

    [self startFileReader];
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
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(writeLogsToFileIfNeeded:)
                                   userInfo:nil
                                    repeats:NO];
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
    
    [_logsTableView.lines addObject:line];
    [_logsTableView reloadData];
    
    if (autoScroll) {
        [_logsTableView scrollToEndOfDocument:nil];
    }
}


@end
