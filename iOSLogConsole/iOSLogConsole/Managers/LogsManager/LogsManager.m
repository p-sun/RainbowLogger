//
//  LogsManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsManager.h"
#import <Foundation/Foundation.h>

@implementation LogsManager {
    NSMutableArray<NSString *> *_allLogs;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allLogs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)clearLogs {
    _allLogs = [[NSMutableArray alloc] init];
}

- (NSArray<Log *>*)getLogs {
    return _allLogs;
}

- (void)appendLogs:(NSArray<Log *>*)logs {
    [_allLogs addObjectsFromArray:logs];
    
    // To limit memeory usage,
    // if we exceed the max number of lines, keep only the last half of the logs in memory
    int maxLines = 10000; // Around 70mb
    int halfOfMaxLine = maxLines / 2;
    if ([_allLogs count] > maxLines) {
        // The first value of NSRange is the start index, second is the length
        // So to get last 4 elements in an array of length 10: NSMakeRange{10 - 4, 4}
        // to get items at index 6, 7, 8, 9
        NSArray *subArrayLogs = [_allLogs subarrayWithRange:NSMakeRange(([_allLogs count] - halfOfMaxLine), halfOfMaxLine)];
        _allLogs = [NSMutableArray arrayWithArray:subArrayLogs];
        [_delegate didChangeLogs:_allLogs];
    } else {
        [_delegate didAppendLogs:logs];
    }
}

@end
