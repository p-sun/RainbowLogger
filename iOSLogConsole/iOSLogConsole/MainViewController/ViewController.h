//
//  ViewController.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogsTableView.h"
#import "FiltersTableView.h"
#import "FileReader.h"
#import "LogsManager.h"
#import "FiltersManager.h"
#import "LogsScrollView.h"
#import "LogsTextView.h"

@interface ViewController : NSViewController <FileReaderDelegate, FiltersTableViewDelegate, LogsManagerDelegate, LogsScrollViewDelegate>

@property (nonatomic, strong) FileReader *fileReader;
@property (nonatomic, readonly) BOOL hasReadLine;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL shouldAutoScroll;

@property (nonatomic, readonly) FiltersManager *filtersManager;
@property (nonatomic, readonly) LogsManager *logsManager;

@property (weak) IBOutlet LogsTextView *logsTextView;
@property (weak) IBOutlet FiltersTableView *filtersTableView;
@property (weak) IBOutlet NSTextField *addFilterTextField;
@property (weak) IBOutlet NSButton *autoscrollButton;

- (IBAction)addFilterButtonPressed:(id)sender;
- (IBAction)addFilterOnTextFieldEnter:(NSTextField *)sender;
- (IBAction)trashPressed:(id)sender;
- (IBAction)pauseButtonToggled:(NSButton *)sender;
- (IBAction)autoscrollButtonToggled:(NSButton *)sender;

@end

