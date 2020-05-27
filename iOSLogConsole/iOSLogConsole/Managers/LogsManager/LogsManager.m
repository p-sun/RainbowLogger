//
//  LogsManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsManager.h"

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

- (void)addLog:(NSString*)log passingFilters:(NSArray<Filter *>*)filters {
    _allLogs = [_allLogs arrayByAddingObject:log];
    
    if ([LogsManager doesLog:log passFilters:filters]) {
        _filteredLogs = [_filteredLogs arrayByAddingObject:log];
        [_delegate didChangeFilteredLogs:_filteredLogs];
    }
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

// TODO
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
                // TODO
                break;
            case FilterByTypeNoFilter:
                break;
        }
    }

    return !hasAOneOrMoreOfFilter || passOneOrMoreOfFilter;
}

@end
