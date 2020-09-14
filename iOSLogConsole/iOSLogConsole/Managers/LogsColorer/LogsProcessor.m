//
//  LogsColorer.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-09-13.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsProcessor.h"
#import "Log.h"

@implementation LogsProcessor

#pragma mark - Color Logs with Filters

+ (NSAttributedString *)coloredLinesFromLogs:(NSArray<NSString *>*)logs filteredBy:(NSArray<Filter *>*)filters {
    
    NSMutableAttributedString *lines = [[NSMutableAttributedString alloc] initWithString:@""];
    for (NSString *log in logs) {
        if ([LogsProcessor doesLog:log passFilters:filters]) {
            NSAttributedString *coloredLog = [LogsProcessor coloredLog:log usingFilters:filters];
            [lines appendAttributedString:coloredLog];
            [lines appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }
    
    return lines;
}

+ (NSAttributedString *)coloredLog:(NSString *)log usingFilters:(NSArray<Filter *>*)filters {
    NSError *error = NULL;
    NSMutableAttributedString *coloredString = [[NSMutableAttributedString alloc] initWithString:log];
    
    [coloredString addAttributes:@{
        NSForegroundColorAttributeName:[NSColor whiteColor],
        NSFontAttributeName:[NSFont fontWithName:@"Menlo" size:13],
    } range:NSMakeRange(0, [log length])];

    for (Filter* filter in filters) {
        if (!filter.isEnabled) {
            continue;
        }
        NSString *regexPattern;
        if (filter.type == FilterByTypeRegex) {
            regexPattern = filter.text;
        } else {
            regexPattern = [NSRegularExpression escapedPatternForString:filter.text];
        }
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexPattern
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        NSRange searchedRange = NSMakeRange(0, [log length]);
        NSArray* matches = [regex matchesInString:log options:0 range: searchedRange];
        for (NSTextCheckingResult *match in matches) {
            FilterColorPopupInfo *info = [Filter colorPopupInfos][filter.colorTag];
            [coloredString addAttributes:@{
                NSForegroundColorAttributeName:info.color,
            } range:match.range];
        }
    }
    
    return coloredString;
}

#pragma mark - Filter Logs

+ (BOOL)doesLog:(NSString *)log passFilters:(NSArray<Filter *>*)filters {
    BOOL hasAOneOrMoreOfFilter = NO;
    BOOL passOneOrMoreOfFilter = NO;

    for (Filter *filter in filters) {
        if (!filter.isEnabled) {
            continue;
        }
        switch (filter.type) {
            case FilterByTypeMustContain:
                if (![log localizedCaseInsensitiveContainsString:filter.text]) {
                    return NO;
                }
                break;
            case FilterByTypeMustNotContain:
                if ([log localizedCaseInsensitiveContainsString:filter.text]) {
                    return NO;
                }
                break;
            case FilterByTypeContainsOneOrMoreOf:
                hasAOneOrMoreOfFilter = YES;
                if (!passOneOrMoreOfFilter && [log localizedCaseInsensitiveContainsString:filter.text]) {
                    passOneOrMoreOfFilter = YES;
                }
                break;
            case FilterByTypeContainsAnyOf:
                if ([log localizedCaseInsensitiveContainsString:filter.text]) {
                    return YES;
                }
                break;
            case FilterByTypeRegex:
                if (![LogsProcessor matchesRegexPattern:filter.text forLog:log]) {
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
