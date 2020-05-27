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

- (void)addLog:(NSString*)log passingFilters:(NSArray<Filter *>*)filters {
    _allLogs = [_allLogs arrayByAddingObject:log];
    
    if ([LogsManager doesLog:log passFilters:filters]) {
        _filteredLogs = [_filteredLogs arrayByAddingObject:log];
        [_delegate didChangeFilteredLogs:_filteredLogs];
    }
}

- (void)filterLogsBy:(NSArray<Filter *>*)filters {
    NSArray<NSString *>* newFilteredLogs = [LogsManager logs:_allLogs filteredBy:filters];
    if (![newFilteredLogs isEqualToArray:_filteredLogs]) {
        _filteredLogs = newFilteredLogs;
        [_delegate didChangeFilteredLogs:_filteredLogs];
    }
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
    if (filters.count == 0) {
        return true;
    }
    // Must contain ALL the contains
    
    // Must contain ALL the Regexes
    
    // Must contain >= of ContainsAnyOF
    
    // Must contain NONe of the NOTContains
    
    for (Filter *filter in filters) {
        if (filter.type == FilterByTypeContains) {
            if ([log containsString:filter.text]) {
                return true;
            }
        } else if (filter.type == FilterByTypeNone) {
            if ([log containsString:filter.text]) {
                return false;
            }
        } else if (filter.type == FilterByTypeRegex) {
            // TODO
        } else if (filter.type == FilterByTypeContainsAnyOf) {
            // TODO
        }
    }
    
    return false;
}

@end
