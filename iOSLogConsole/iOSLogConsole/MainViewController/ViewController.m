//
//  ViewController.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)awakeFromNib {
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.227f
                                                                   green:0.251f
                                                                    blue:0.337
                                                                   alpha:0.8].CGColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.logsTableView setupTable];
    [self.filtersTableView setupTable];

    [self setupSimulatorFile];
}

- (void)setupSimulatorFile {
     system("xcrun simctl spawn booted log stream --level=debug > test.log&");
    
    self.fileReader = [[FileReader alloc] initWithFilePath:@"test.log"];
    [self.fileReader setDelegate:self];
}

#pragma mark - FileReaderDelegate

-(void)fileReaderDidReadLine:(NSString *)line {
    NSLog(@"%@", line);
}

@end
