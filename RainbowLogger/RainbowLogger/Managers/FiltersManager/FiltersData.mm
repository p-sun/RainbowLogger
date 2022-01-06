//
//  FiltersData.cpp
//  RainbowLogger
//
//  Created by Paige Sun on 12/28/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//

#include "FiltersData.h"
#include <pthread.h>

@implementation FiltersData{
  pthread_mutex_t _mutex;
  NSArray<Filter *>* _filters;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _filters = [self _loadFiltersData];
    pthread_mutex_init(&_mutex, NULL);
  }
  return self;
}

- (NSArray<Filter *>*)getFilters {
  return _filters;
}

# pragma mark UpdateFilters Delegate

-(void)setFilters:(new_filters_provider)getNewFilters {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
    
    pthread_mutex_lock(&strongSelf->_mutex);
    strongSelf->_filters = getNewFilters(_filters);
    [_delegate filtersDidUpdate:_filters];
    pthread_mutex_unlock(&strongSelf->_mutex);
    [strongSelf saveFilters];
  }
}

# pragma mark Save and Load Filters from File

-(void)saveFilters {
  pthread_mutex_lock(&_mutex);
  NSError *error;
  NSArray *myFilters = _filters;
  NSData *encodedFilters = [NSKeyedArchiver archivedDataWithRootObject:myFilters requiringSecureCoding:YES error:&error];
  [NSUserDefaults.standardUserDefaults setObject:encodedFilters forKey:@"filters"];
  if (error) {
    NSLog(@"(PAIGE) Error with saving filters: %@", error);
  }
  pthread_mutex_unlock(&_mutex);
}

-(NSArray<Filter *>*)_loadFiltersData {
  NSError *error;
  NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:@"filters"];
  NSSet *set = [[NSSet alloc] init];
  [set setByAddingObject:[Filter class]];
  
  NSSet *classes = [[NSSet alloc] initWithArray:@[Filter.class, NSArray.class]];
  NSArray *storedFilters = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
  if (error) {
    NSLog(@"(PAIGE) Error with loading filters: %@", error.localizedDescription);
  }
  return storedFilters != nil ? storedFilters : [[NSArray alloc] init];
}

# pragma mark Filters Summary

// See tests in FilterDataTests
- (NSString*)getFiltersSummary {
  NSArray *filters = [_filters copy];
  NSMutableArray<Filter *> *mustContain = [[NSMutableArray alloc] init];
  NSMutableArray<Filter *> *containsAny = [[NSMutableArray alloc] init];
  
  for (Filter *filter in filters) {
    if (!filter.isEnabled) {
      continue;
    }
    switch (filter.condition) {
      case FilterConditionMustContain:
        [mustContain addObject:filter];
        break;
      case FilterConditionMustNotContain:
        [mustContain addObject:filter];
        break;
      case FilterConditionContainsAny:
        [containsAny addObject:filter];
        break;
      case FilterConditionColorContainingText:
        break;
      case FilterConditionSize:
        NSAssert(NO, @"(PAIGE) FilterConditionSize should be used for enum size only");
        break;
    }
  }
  
  // e.g. @"(MustContain1 && MustContain2 && MustNotContain3)"
  NSMutableString *mcSummary;
  if ([mustContain count] > 0) {
    mcSummary = [[NSMutableString alloc] init];
    [mcSummary appendString:@"("];
    Filter *firstFilter = [mustContain firstObject];
    if (firstFilter.condition == FilterConditionMustNotContain) {
      [mcSummary appendString:@"!"];
    }
    [mcSummary appendString:firstFilter.text];
    
    for (int i=1; i<mustContain.count; i++) {
      [mcSummary appendString:@" AND "];
      Filter *nextFilter = [mustContain objectAtIndex:i];
      if (nextFilter.condition == FilterConditionMustNotContain) {
        [mcSummary appendString:@"!"];
      }
      [mcSummary appendString:nextFilter.text];
    }
    [mcSummary appendString:@")"];
  }
  
  // e.g. @"ContainsAny5 OR ContainsAny6"
  NSMutableString *caSummary;
  if ([containsAny count] > 0) {
    caSummary = [[NSMutableString alloc] init];
    if (mcSummary) {
      [caSummary appendString:@" OR "];
    }
    [caSummary appendString:[containsAny firstObject].text];
    
    for (int i=1; i<containsAny.count; i++) {
      [caSummary appendString:@" OR "];
      [caSummary appendString:[containsAny objectAtIndex:i].text];
    }
  }
  
  // e.g. @"Logs are filtered with condition: ": (MustContain1 && MustContain2 && MustNotContain3) OR ContainsAny5 OR ContainsAny6"
  NSString *prefix = @"Logs are filtered with condition: ";

  NSMutableString *summary = [[NSMutableString alloc] initWithString:prefix];
  if (!mcSummary && !caSummary) {
    return @"";
  }
  if (mcSummary) {
    [summary appendString:mcSummary];
  }
  if (caSummary) {
    [summary appendString:caSummary];
  }
  return summary;
}

@end
