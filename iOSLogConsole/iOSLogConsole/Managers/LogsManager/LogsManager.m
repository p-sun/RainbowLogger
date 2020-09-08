//
//  LogsManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsManager.h"
#import <Foundation/Foundation.h>

@implementation LogsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allLogs = [[NSArray alloc] init];
        _filteredLogs = [[NSArray alloc] init];
    }
    return self;
}

- (void)clearLogs {
    _allLogs = [[NSArray alloc] init];
    _filteredLogs = [[NSArray alloc] init];
    [_delegate didChangeFilteredLogs:_filteredLogs];
}

- (void)addLogs:(NSArray<NSString*>*)logs passingFilters:(NSArray<Filter *>*)filters {
    _allLogs = [_allLogs arrayByAddingObjectsFromArray:logs];
    
    // To limit memeory usage,
    // if we exceed the max number of lines, keep only the last half of the logs in memory
    int maxLines = 1000;
    int halfOfMaxLine = maxLines / 2;
    if ([_allLogs count] > maxLines) {
        // The first value of NSRange is the start index, second is the length
        // So to get last 4 elements in an array of length 10: NSMakeRange{10 - 4, 4}
        // to get items at index 6, 7, 8, 9
        _allLogs = [_allLogs subarrayWithRange:NSMakeRange(([_allLogs count] - halfOfMaxLine), halfOfMaxLine)];
    }
    
    [self filterLogsBy:filters];
}

- (void)filterLogsBy:(NSArray<Filter *>*)filters {
    NSArray<NSString *>* newFilteredLogs = [LogsManager logs:_allLogs filteredBy:filters];
    _filteredLogs = newFilteredLogs;
    [_delegate didChangeFilteredLogs:_filteredLogs];
}

+ (NSArray<NSString *>*)logs:(NSArray<NSString *>*)logs filteredBy:(NSArray<Filter *>*)filters {
    NSMutableArray<NSString *> *filtered = [[NSMutableArray alloc] init];
    for (NSString *log in logs) {
        if ([LogsManager doesLog:log passFilters:filters]) {
            [filtered addObject:log];
        }
    }
    return filtered;
}

+ (BOOL)doesLog:(NSString *)log passFilters:(NSArray<Filter *>*)filters {
    BOOL hasAOneOrMoreOfFilter = NO;
    BOOL passOneOrMoreOfFilter = NO;

    for (Filter *filter in filters) {
        if (!filter.isEnabled) {
            continue;
        }
        switch (filter.type) {
            case FilterByTypeMustContain:
                if (![log containsString:filter.text]) {
                    return NO;
                }
                break;
            case FilterByTypeMustNotContain:
                if ([log containsString:filter.text]) {
                    return NO;
                }
                break;
            case FilterByTypeContainsOneOrMoreOf:
                hasAOneOrMoreOfFilter = YES;
                if (!passOneOrMoreOfFilter && [log containsString:filter.text]) {
                    passOneOrMoreOfFilter = YES;
                }
                break;
            case FilterByTypeContainsAnyOf:
                if ([log containsString:filter.text]) {
                    return YES;
                }
                break;
            case FilterByTypeRegex:
                if (![LogsManager matchesRegexPattern:filter.text forLog:log]) {
                    return NO;
                }
                break;
            case FilterByTypeNoFilter:
                break;
        }
    }
    
    return !hasAOneOrMoreOfFilter || passOneOrMoreOfFilter;
}

+ (BOOL)matchesRegexPattern:(NSString*)pattern forLog:(NSString *)log {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:0
                                  error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:log
                                                        options:0
                                                          range:NSMakeRange(0, [log length])];
    return numberOfMatches > 0;
}

@end
