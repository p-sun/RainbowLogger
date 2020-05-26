//
//  Filter.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "Filter.h"

@implementation Filter

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        self.type = FilterByTypeContains;
        self.text = text;
        self.color = [[FilterColor alloc] initWithColor:[NSColor clearColor] name:@""];
        self.isEnabled = YES;
    }
    return self;
}

@end
