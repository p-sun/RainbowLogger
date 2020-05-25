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

@interface ViewController : NSViewController <FileReaderDelegate>

@property (weak) IBOutlet LogsTableView *logsTableView;
@property (weak) IBOutlet FiltersTableView *filtersTableView;
@property (nonatomic, strong) FileReader *fileReader;

@end

