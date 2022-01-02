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

@interface ViewController : NSViewController <FileReaderDelegate, FiltersManagerDelegate, FiltersTableViewDelegate, LogsManagerDelegate, LogsScrollViewDelegate, NSTextViewDelegate>

// Data - Logs and Filter
@property (nonatomic, strong) FileReader *fileReader;
@property (nonatomic, readonly) BOOL hasReadLine;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL shouldAutoScroll;

@property (nonatomic, readonly) FiltersManager *filtersManager;
@property (nonatomic, readonly) LogsManager *logsManager;

// Outlets - Logs and Filter
@property (weak) IBOutlet LogsTextView *logsTextView;
@property (weak) IBOutlet FiltersTableView *filtersTableView;
@property (weak) IBOutlet NSTextField *addFilterTextField;
@property (weak) IBOutlet NSButton *autoscrollButton;

// Outlets - Customize Script
@property (weak) IBOutlet NSSplitView *verticalSplitView;
@property (weak) IBOutlet NSView *rightPanel;
@property (unsafe_unretained) IBOutlet NSTextView *customizeScriptTextView;
@property (weak) IBOutlet NSButton *customizeScriptApplyButton;
@property (weak) IBOutlet NSButton *customizeScriptCancelChangesButton;

// IBActions - Customize Script Panel
- (IBAction)customizeCancelPressed:(id)sender;
- (IBAction)customizeDefaultPressed:(id)sender;
- (IBAction)customizeApplyPressed:(id)sender;
- (IBAction)customizeClosePanelPressed:(id)sender;

// IBActions - Top Logs Menu
- (IBAction)attachLoggerPressed:(id)sender;
- (IBAction)editAttachScriptPressed:(id)sender;
- (IBAction)clearLogs:(id)sender;
- (IBAction)pauseButtonToggled:(NSButton *)sender;
- (IBAction)autoscrollButtonToggled:(NSButton *)sender;

// IBActions - Bottom Filters Menu
- (IBAction)addFilterButtonPressed:(id)sender;
- (IBAction)addFilterOnTextFieldEnter:(NSTextField *)sender;
- (IBAction)deleteSelectedFilter:(id)sender;

@end

