//
//  FiltersManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersManager.h"

@implementation FiltersManager {
  FiltersData *_filtersData;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _filtersData = [[FiltersData alloc] init];
    _filtersData.delegate = self;
  }
  return self;
}

- (NSArray<Filter *>*)getFilters {
  return [_filtersData getFilters];
}

# pragma mark Filter Modifications

- (void)clearFilters {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    return [[NSArray alloc] init];
  }];
}

- (void)appendFilter:(Filter *)filter {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    return [currentFilters arrayByAddingObject:filter];
  }];
}

- (void)deleteFilterAtIndex:(NSInteger)index {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    NSMutableArray<Filter *> *filters = [[NSMutableArray alloc] initWithArray:currentFilters];
    
    if (index > 0) {
      NSRange frontRange = NSMakeRange(0, index);
      [filters addObjectsFromArray: [currentFilters subarrayWithRange: frontRange]];
    }
    if (index < currentFilters.count - 1) {
      NSInteger length = currentFilters.count - 1 - index;
      NSRange backRange = NSMakeRange(index + 1, length);
      [filters addObjectsFromArray: [currentFilters subarrayWithRange: backRange]];
    }
    return filters;
  }];
}

- (void)replaceFilter:(Filter *)filter atIndex:(NSInteger)index {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    NSMutableArray<Filter *> *filters = [[NSMutableArray alloc] initWithArray:currentFilters];
    
    if (index > 0) {
      NSRange frontRange = NSMakeRange(0, index);
      [filters addObjectsFromArray: [currentFilters subarrayWithRange: frontRange]];
    }
    [filters addObject:filter];
    if (index < currentFilters.count - 1) {
      NSInteger length = currentFilters.count - 1 - index;
      NSRange backRange = NSMakeRange(index + 1, length);
      [filters addObjectsFromArray: [currentFilters subarrayWithRange: backRange]];
    }
    return filters;
  }];
}

- (void)moveFilterFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    NSMutableArray<Filter *> *filters = [[NSMutableArray alloc] initWithArray:currentFilters];
    
    Filter *filterToMove = [filters objectAtIndex:fromIndex];
    [filters insertObject:filterToMove atIndex:toIndex];
    
    if (fromIndex < toIndex) {
      [filters removeObjectAtIndex:fromIndex];
    } else {
      [filters removeObjectAtIndex:fromIndex+1];
    }
    return filters;
  }];
}

# pragma mark FiltersDataDelegate

-(void)filtersDidUpdate: (NSArray<Filter *>*) filters {
  [self.delegate filtersDidUpdate:filters];
}

@end
