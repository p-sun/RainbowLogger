//
//  LogsColorer.m
//  RainbowLogger
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
  NSMutableAttributedString *newLog = [[NSMutableAttributedString alloc] initWithString:log];
  
  NSColor *almostWhite = [NSColor NSColorFrom255Red:244 green:248 blue:248];
  [newLog addAttributes:@{
    NSForegroundColorAttributeName:almostWhite,
    NSFontAttributeName:[NSFont fontWithName:@"Menlo" size:13],
  } range:NSMakeRange(0, [newLog length])];
  
  for (Filter* filter in filters) {
    if (!filter.isEnabled) {
      continue;
    }
    NSString *regexPattern;
    if (filter.isRegex) {
      regexPattern = filter.text;
    } else {
      regexPattern = [NSRegularExpression escapedPatternForString:filter.text];
    }
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regexPattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange searchedRange = NSMakeRange(0, [[newLog string] length]);
    NSArray* matches = [regex matchesInString:[newLog string] options:0 range: searchedRange];
    
    NSUInteger locationOffset = 0;
    for (NSTextCheckingResult *match in matches) {
      // Add offset from the replacement of texts
      NSRange rangeWithOffset = NSMakeRange(match.range.location + locationOffset, match.range.length);
      
      // Color text
      FilterColorPopupInfo *info = [FilterColorPopupInfo colorPopupInfos][filter.colorTag];
      [newLog addAttributes:@{NSForegroundColorAttributeName:info.color} range:rangeWithOffset];
      
      // Replace text if needed
      if ([filter.replacementText length] > 0) {
        [newLog replaceCharactersInRange:rangeWithOffset withString:filter.replacementText];
        locationOffset += filter.replacementText.length - rangeWithOffset.length;
      }
    }
  }
  
  return newLog;
}

#pragma mark - Filter Logs

+ (BOOL)doesLog:(NSString *)log passFilters:(NSArray<Filter *>*)filters {
  BOOL hasContainsAnyFilter = NO;
  BOOL passContainsAnyFilter = NO;
  
  for (Filter *filter in filters) {
    if (!filter.isEnabled) {
      continue;
    }
    switch (filter.condition) {
      case FilterConditionContainsAll:
        if (![LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
          return NO;
        }
        break;
      case FilterConditionNotContains:
        if ([LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
          return NO;
        }
        break;
      case FilterConditionContainsAny:
        hasContainsAnyFilter = YES;
        if (!passContainsAnyFilter && [LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
          passContainsAnyFilter = YES;
        }
        break;
      case FilterConditionColorContainingText:
        break; // For coloring text only, no filter
    }
  }
  
  return hasContainsAnyFilter ? passContainsAnyFilter : YES;
}

+ (BOOL)matchesPattern:(NSString*)pattern isRegex:(BOOL)isRegex forLog:(NSString *)log {
  if (isRegex) {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:0
                                  error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:log
                                                        options:0
                                                          range:NSMakeRange(0, [log length])];
    return numberOfMatches > 0;
  } else {
    return [log localizedCaseInsensitiveContainsString:pattern];
  }
}

@end