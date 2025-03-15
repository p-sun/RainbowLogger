//
//  LogsManager.m
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsManager.h"
#import <Foundation/Foundation.h>
#include <pthread.h>

@implementation LogsManager {
  NSMutableArray<Log *> *_allLogs;
  NSMutableArray<Log *> *_nextLogs;
  pthread_mutex_t _nextLogsMutex;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _allLogs = [[NSMutableArray alloc] init];
    _nextLogs = [[NSMutableArray alloc] init];
    pthread_mutex_init(&_nextLogsMutex, NULL);
  }
  return self;
}

- (void)clearLogs {
  _allLogs = [[NSMutableArray alloc] init];
  _nextLogs = [[NSMutableArray alloc] init];
}

- (NSArray<Log *>*)getNextLogs {
  NSUInteger MAX_LOGS_TO_RETURN = 300;
  pthread_mutex_lock(&_nextLogsMutex);

  NSArray *nextLogs;
  if ([_nextLogs count] <= MAX_LOGS_TO_RETURN) {
    nextLogs = [_nextLogs copy];
    [_nextLogs removeAllObjects];
  } else {
    NSRange range = NSMakeRange(0, MAX_LOGS_TO_RETURN - 1);
    nextLogs = [_nextLogs subarrayWithRange:range];
    [_nextLogs removeObjectsInRange:range];
  }
  
  pthread_mutex_unlock(&_nextLogsMutex);
  return nextLogs;
}

- (NSArray<Log *>*)getLogs {
  return [_allLogs copy];
}

- (void)appendLogs:(NSArray<Log *>*)logs {
  pthread_mutex_lock(&_nextLogsMutex);
  [_allLogs addObjectsFromArray:logs];
  [_nextLogs addObjectsFromArray:logs];
  pthread_mutex_unlock(&_nextLogsMutex);
  
  // To limit memeory usage,
  // if we exceed the max number of lines, keep only the last half of the logs in memory
  int maxLines = 10000; // Around 70mb
  int remainingLines = 1000;
  if ([_allLogs count] > maxLines) {
    // The first value of NSRange is the start index, second is the length
    // So to get last 4 elements in an array of length 10: NSMakeRange{10 - 4, 4}
    // to get items at index 6, 7, 8, 9
    NSArray *subArrayLogs = [_allLogs subarrayWithRange:NSMakeRange(([_allLogs count] - remainingLines), remainingLines)];
    _allLogs = [NSMutableArray arrayWithArray:subArrayLogs];
    [_delegate didChangeLogs:@[]];
  } else {
    [_delegate didAppendLogs:logs];
  }
}

@end
