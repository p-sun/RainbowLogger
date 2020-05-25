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
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
    target:self
    selector:@selector(onTick:)
    userInfo:nil
    repeats:YES];
}

- (void)setupSimulatorFile {
     system("xcrun simctl spawn booted log stream --level=debug > test.log&");
    
//    self.fileStreamer = [[FileStreamer alloc] init];
//    [self.fileStreamer openFileWithFileAtPath:@"test.log"];
    
    self.fileReader = [[FileReader alloc] initWithFilePath:@"test.log"];
    
    [self readLines];
    
//    NSString * line = nil;
//    while ((line = [self.fileReader readLine])) {
//      NSLog(@"read line: %@", line);
//    }
//
//    self.documentReader = [[DocumentReader alloc] init];
//    [self.documentReader openFileWithFilename:"test.log"];
//    [self.documentReader readFile];
}

-(void)onTick:(NSTimer *)timer {
//    NSString *line = [self readLine:_inputStream];
//    NSLog(line);
//    [_inputStream open];
    
//    NSString * line = nil;
//    while ((line = [self.fileReader readLine])) {
//      NSLog(@"onTick line: %@", line);
//    }
    [self readLines];
}

-(void)readLines {
    [self.fileReader enumerateLinesUsingBlock:^(NSString *line) {
        NSLog(@"%@", line);
    }];
}

@end
