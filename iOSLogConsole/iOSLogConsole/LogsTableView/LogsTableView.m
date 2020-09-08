//
//  LogsTableView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "LogsTableView.h"
#include <pthread.h>

@implementation LogsTableView {
    pthread_mutex_t mutex;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&mutex, NULL);
    }
    return self;
}

- (void)setupTable {
    [self setDelegate:self];
    [self setDataSource:self];
    
    _attributedLines = [[NSMutableArray alloc] init];

    self.tableColumns[0].width = NSScreen.mainScreen.frame.size.width;
    _didSetupTable = YES;
    [self reloadData];
}

- (void)addAttributedLine:(NSAttributedString *)attributedLine shouldAutoscroll:(BOOL)shouldAutoscroll {
    if (!_isLoadingTable) {
        _isLoadingTable = YES;
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            [strongSelf.attributedLines addObject:attributedLine];
            
            NSIndexSet *rowIndex = [[NSIndexSet alloc] initWithIndex:strongSelf.attributedLines.count - 1];
            NSIndexSet *columnIndex = [[NSIndexSet alloc] initWithIndex:0];
            [strongSelf reloadDataForRowIndexes:rowIndex columnIndexes:columnIndex];
            if (shouldAutoscroll) {
                [strongSelf scrollToEndOfDocument:nil];
            }
            strongSelf.isLoadingTable = NO;
        });
    }
}

- (void)setAttributedLines:(NSArray<NSAttributedString *> *)attributedLines shouldAutoscroll:(BOOL)shouldAutoscroll {

    __weak __typeof__(self) weakSelf = self;

    if (_isLoadingTable) {
         return;
     }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (!strongSelf.isLoadingTable) {
            pthread_mutex_lock(&strongSelf->mutex);
            strongSelf.isLoadingTable = YES;
            [strongSelf.attributedLines setArray:attributedLines];
            
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                if (shouldAutoscroll) {
                    [strongSelf scrollPoint: NSMakePoint(0, strongSelf.frame.size.height)];
                }
                strongSelf.isLoadingTable = NO;
                pthread_mutex_unlock(&strongSelf->mutex);
            }];
            [strongSelf reloadData];
            [CATransaction commit];
        }
    });
}

# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfColumns {
    return _didSetupTable ? _columnsCount : 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _attributedLines.count;
}

# pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *view = [self makeViewWithIdentifier:@"LogsCellView" owner:self];
    if (row < _attributedLines.count) {
        [[view textField] setAttributedStringValue:_attributedLines[row]];
        [[view textField] setSelectable:YES];
    }
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.selectedRow;
    if (row != 0) {
        // Copy line to Pasteboard
        NSString *line = _attributedLines[row].string;
        NSLog(@"^^^^^^ Copied line to pasteboard: %@", line);
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:@[NSPasteboardTypeString] owner:nil];
        [pasteboard setString:line forType:NSPasteboardTypeString];
    }
}

@end
