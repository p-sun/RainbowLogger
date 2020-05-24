//
//  LogsTablewView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsTablewView.h"

@implementation LogsTablewView

- (void)awakeFromNib {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor greenColor].CGColor;
}

@end
