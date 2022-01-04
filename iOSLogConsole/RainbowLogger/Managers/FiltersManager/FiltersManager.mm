//
//  FiltersManager.m
//  RainbowLogger
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

- (void)toggleRegexForFilterAtIndex:(NSInteger)index {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    NSMutableArray<Filter *> *filters = [[NSMutableArray alloc] initWithArray:currentFilters];
    Filter *filterToChange = [filters objectAtIndex:index];
    filterToChange.isRegex = !filterToChange.isRegex;
    return filters;
  }];
}

- (void)deleteFiltersAtIndexes:(NSIndexSet*)indexes {
  [_filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    NSMutableArray<Filter *> *filters = [[NSMutableArray alloc] initWithArray:currentFilters];
    [filters removeObjectsAtIndexes:indexes];
    return filters;
  }];
}

- (void)deleteFilterAtIndex:(NSInteger)index {
  NSIndexSet *rowIndex = [[NSIndexSet alloc] initWithIndex:index];
  [self deleteFiltersAtIndexes:rowIndex];
}

- (void)changeFilter:(Filter *)filter atIndex:(NSInteger)index {
  [_filtersData saveFilters];
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
