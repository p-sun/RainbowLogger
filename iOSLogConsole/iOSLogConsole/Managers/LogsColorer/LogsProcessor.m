//
//  LogsColorer.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-09-13.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsProcessor.h"
#import "Log.h"
#import "NSColorExtensions.h"

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
    
    NSColor *almostWhite = [NSColor NSColorFrom255Red:244 green:248 blue:248];
    [coloredString addAttributes:@{
        NSForegroundColorAttributeName:almostWhite,
        NSFontAttributeName:[NSFont fontWithName:@"Menlo" size:13],
    } range:NSMakeRange(0, [log length])];

    for (Filter* filter in filters) {
        if (!filter.isEnabled) {
            continue;
        }
        NSString *regexPattern;
        if (filter.type == FilterByTypeColorContainingTextRegex
            || filter.type == FilterByTypeContainsAllRegex
            || filter.type == FilterByTypeContainsAnyRegex
            || filter.type == FilterByTypeNotContainsRegex) {
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
  BOOL hasContainsAnyFilter = NO;
  BOOL passContainsAnyFilter = NO;
  
  for (Filter *filter in filters) {
    if (!filter.isEnabled) {
      continue;
    }
    switch (filter.type) {
      case FilterByTypeContainsAll:
        if (![log localizedCaseInsensitiveContainsString:filter.text]) {
          return NO;
        }
        break;
      case FilterByTypeNotContains:
        if ([log localizedCaseInsensitiveContainsString:filter.text]) {
          return NO;
        }
        break;
      case FilterByTypeContainsAny:
        hasContainsAnyFilter = YES;
        if (!passContainsAnyFilter && [log localizedCaseInsensitiveContainsString:filter.text]) {
          passContainsAnyFilter = YES;
        }
        break;
      case FilterByTypeContainsAllRegex:
        if (![LogsProcessor matchesRegexPattern:filter.text forLog:log]) {
          return NO;
        }
        break;
      case FilterByTypeNotContainsRegex:
        if ([LogsProcessor matchesRegexPattern:filter.text forLog:log]) {
          return NO;
        }
        break;
      case FilterByTypeContainsAnyRegex:
        hasContainsAnyFilter = YES;
        if (!passContainsAnyFilter && [LogsProcessor matchesRegexPattern:filter.text forLog:log]) {
          passContainsAnyFilter = YES;
        }
        break;
      case FilterByTypeColorContainingText:
      case FilterByTypeColorContainingTextRegex:
        break; // For coloring text only, no filter
    }
  }
  
  return hasContainsAnyFilter ? passContainsAnyFilter : YES;
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
