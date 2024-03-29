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
  NSArray *enabledFilters = [LogsProcessor getEnabledFiltersFrom:filters];
  
  for (NSString *log in logs) {
    if ([LogsProcessor doesLog:log passFilters:enabledFilters]) {
      NSAttributedString *coloredLog = [LogsProcessor coloredLog:log usingFilters:enabledFilters];
      [lines appendAttributedString:coloredLog];
      [lines appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
  }
  
  return lines;
}

+ (NSArray<Filter *>*)getEnabledFiltersFrom:(NSArray<Filter *>*)filters {
  NSMutableArray *enabledFilers = [NSMutableArray new];
  for (Filter *filter in filters) {
    if (filter.isEnabled) {
      [enabledFilers addObject:filter];
    }
  }
  return enabledFilers;
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
        if ([filter.replacementText isEqualToString:@"EMPTY"]) {
          [newLog deleteCharactersInRange:rangeWithOffset];
          locationOffset -= rangeWithOffset.length;
        } else {
          [newLog replaceCharactersInRange:rangeWithOffset withString:filter.replacementText];
          locationOffset += filter.replacementText.length - rangeWithOffset.length;
        }
      }
    }
  }
    
  return [LogsProcessor padLogByAligningString:@"******" toLocation:10 fromLog:newLog];
}

/*
 If the first occurence of "******"s starts before toLocation, then add spaces to bring it to that location.
 e.g. if position = 8
 "> CPP ****** message"   --becomes-->    "> CPP   ****** message"
 **/
+ (NSAttributedString *)padLogByAligningString:(NSString*)string toLocation:(NSUInteger)toLocation fromLog:(NSMutableAttributedString*)log {
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:[NSRegularExpression escapedPatternForString:string]
                                options:NSRegularExpressionCaseInsensitive
                                error:&error];
  NSRange searchedRange = NSMakeRange(0, [[log string] length]);
  
  NSTextCheckingResult* firstMatch = [regex firstMatchInString:[log string] options:0 range:searchedRange];
  if (firstMatch) {
    // If the string starts before the toLocation, add spaces before the string
    if (firstMatch.range.location < toLocation) {
      NSUInteger dx = toLocation - firstMatch.range.location;
      NSString *spacesToAdd = [@"" stringByPaddingToLength:dx withString: @" " startingAtIndex:0];
      [log replaceCharactersInRange:NSMakeRange(1, 0) withString:spacesToAdd];
    }
  }

  return log;
}

#pragma mark - Filter Logs

/*
 Each log displayed must pass the set of all filters.

 - Each log must satisfy all "[and ] Contain" and all "[and ] Not Contain" conditions.
 - A log that satisfies any "[or  ] Contain" condition is displayed.
 - A "None" conditions does not remove any logs. It is only used for the Color and Replace Text features.
 
 TODO: Write test for filtering logs.
 
 Run this Script to test:
 "(MustContain1 AND MustContain2 AND MustNotContain3) ContainsAny4 OR ContainsAny5"
 echo "MustContain1 MustContain2 -- should pass"
 echo "MustContain1 MustContain2 ContainsAny4 -- should pass"
 echo "ContainsAny4 -- should pass"
 echo "ContainsAny5 -- should pass"
 echo "MustNotContain3 MustContain1 ContainsAny4 -- should pass"
 echo "MustContain1 MustContain2 MustNotContain3 -- should NOT pass"
 echo "MustContain1 -- should NOT pass"
 echo "MustContain2 -- should NOT pass"
 echo "MustNotContain3 -- should NOT pass"

 **/
+ (BOOL)doesLog:(NSString *)log passFilters:(NSArray<Filter *>*)filters {
  BOOL hasMustContainFilter = NO;
  BOOL hasContainsAnyFilter = NO;
  BOOL hasContainsOnlyFilter = NO;
  for (Filter *filter in filters) {
    switch (filter.condition) {
      case FilterConditionMustContain:
        hasMustContainFilter = YES;
        break;
      case FilterConditionMustNotContain:
        hasMustContainFilter = YES;
        break;
      case FilterConditionContainsAny:
        hasContainsAnyFilter = YES;
        break;
      case FilterConditionContainsOnly:
        hasContainsOnlyFilter = YES;
        break;
      case FilterConditionColorContainingText:
        break; // For coloring text only, no filter
      case FilterConditionSize:
        NSAssert(NO, @"(PAIGE) FilterConditionSize should be used for enum size only");
        break;
    }
  }
  
  if (hasContainsOnlyFilter) {
    for (Filter *filter in filters) {
      switch (filter.condition) {
        case FilterConditionContainsOnly:
          // If there is at least one "[only] Contain" filter, all other filters are ignored.
          if ([LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
            return YES;
          }
          break;
        case FilterConditionMustContain:
        case FilterConditionMustNotContain:
        case FilterConditionContainsAny:
        case FilterConditionColorContainingText:
          break;
        case FilterConditionSize:
          NSAssert(NO, @"(PAIGE) FilterConditionSize should be used for enum size only");
          break;
      }
    }
    
    return NO;
  }
  
  BOOL passMustContainFilter = hasMustContainFilter;
  BOOL passMustNotContainFilter = hasMustContainFilter;
  for (Filter *filter in filters) {
    switch (filter.condition) {
      case FilterConditionMustContain:
        if (!hasContainsAnyFilter) {
          if (![LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
            return NO;
          }
        } else {
          // If there is a ContainsAny filter, for-loop through all filters to allow ContainsAny to to return early
          if (passMustContainFilter && ![LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
            passMustContainFilter = NO;
          }
        }
        break;
        
      case FilterConditionMustNotContain:
        if (!hasContainsAnyFilter) {
          if ([LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
            return NO;
          }
        } else {
          // If there is a ContainsAny filter, for-loop through all filters to allow ContainsAny to to return early
          if (passMustNotContainFilter && [LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
            passMustNotContainFilter = NO;
          }
        }
        break;
        
      // A Log that passes any ContainsAny Filter always passes this method, even if it doesn't pass any MustContain filters
      case FilterConditionContainsAny:
        if ([LogsProcessor matchesPattern:filter.text isRegex:filter.isRegex forLog:log]) {
          return YES;
        }
        break;
      case FilterConditionColorContainingText:
        break; // For coloring text only, no filter
      case FilterConditionContainsOnly:
        NSAssert(NO, @"(PAIGE) Having a FilterConditionContainsOnly means all other filters are disabled.");
        break;
      case FilterConditionSize:
        NSAssert(NO, @"(PAIGE) FilterConditionSize should be used for enum size only");
        break;
    }
  }
  
  return (hasMustContainFilter && passMustContainFilter && passMustNotContainFilter) || !hasContainsAnyFilter;
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
