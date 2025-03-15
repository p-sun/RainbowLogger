//
//  ViewController.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogsTableView.h"
#import "EditScriptView.h"
#import "ScriptRunner.h"
#import "FiltersManager.h"
#import "FiltersTableView.h"
#import "LogsManager.h"
#import "LogsScrollView.h"
#import "LogsTextView.h"

@interface ViewController : NSViewController <ScriptRunnerDelegate, FiltersManagerDelegate, FiltersTableViewDelegate, LogsManagerDelegate, LogsScrollViewDelegate, EditScriptViewDelegate, NSTextFieldDelegate>

// Data - Logs and Filter
@property (nonatomic, strong) ScriptRunner *scriptRunner;
@property (nonatomic, readonly) BOOL hasReadLine;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL shouldAutoScroll;

@property (nonatomic, readonly) FiltersManager *filtersManager;
@property (nonatomic, readonly) LogsManager *logsManager;

// Outlets - Logs and Filter
@property (weak) IBOutlet LogsTextView *logsTextView;
@property (weak) IBOutlet FiltersTableView *filtersTableView;
@property (weak) IBOutlet NSTextField *filtersSummaryLabel;
@property (weak) IBOutlet NSTextField *addFilterTextField;
@property (weak) IBOutlet NSButton *autoscrollButton;

// Outlets - Script
@property (weak) IBOutlet NSButton *topMenuRunScriptButton;
@property (weak) IBOutlet NSTextField *scriptInputTextField;

// Outlets - Right Pane Edit Script
@property (weak) IBOutlet NSSplitView *verticalSplitView;
@property (weak) IBOutlet NSView *rightPane;
@property (weak) IBOutlet NSView *rightPaneScrollViewContents;
@property (weak) IBOutlet NSScrollView *rightPanelScrollView;

// IBActions - Top Logs Menu
- (IBAction)runScriptPressed:(id)sender;
- (IBAction)editScriptPressed:(id)sender;
- (IBAction)clearLogs:(id)sender;
- (IBAction)pauseButtonToggled:(NSButton *)sender;
- (IBAction)autoscrollButtonToggled:(NSButton *)sender;

// IBActions - Bottom Filters Menu
- (IBAction)addFilterButtonPressed:(id)sender;
- (IBAction)addFilterOnTextFieldEnter:(NSTextField *)sender;
- (IBAction)deleteSelectedFilter:(id)sender;

@end

