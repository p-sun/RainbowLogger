//
//  FiltersManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersManager.h"
#include <pthread.h>

// Given current filters, return new filters
typedef NSArray<Filter *>* (^new_filters_provider)(NSArray<Filter *>* currentFilters);

@implementation FiltersManager{
  pthread_mutex_t mutex;
  NSArray<Filter *>* _filters;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
      _filters = [self _loadFiltersData];
      pthread_mutex_init(&mutex, NULL);
    }
    return self;
}

# pragma mark Filter Modifications
- (NSArray<Filter *>*)getFilters {
  return _filters;
}

- (void)clearFilters {
  [self _updateAndSaveFilters:^NSArray<Filter *> * (NSArray<Filter *> *currentFilters) {
    return [[NSArray alloc] init];
  }];
}

- (void)appendFilter:(Filter *)filter {
  [self _updateAndSaveFilters:^NSArray<Filter *> * (NSArray<Filter *> *currentFilters) {
    return [currentFilters arrayByAddingObject:filter];
  }];
}

- (void)deleteFilterAtIndex:(NSInteger)index {
  [self _updateAndSaveFilters:^NSArray<Filter *> * (NSArray<Filter *> *currentFilters) {
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
  [self _updateAndSaveFilters:^NSArray<Filter *> * (NSArray<Filter *> *currentFilters) {
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
  [self _updateAndSaveFilters:^NSArray<Filter *> * (NSArray<Filter *> *currentFilters) {
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

# pragma mark Save and Load Filters from File

-(void)_saveFiltersData {
    NSError *error;
    NSArray *myFilters = _filters;
    NSData *encodedFilters = [NSKeyedArchiver archivedDataWithRootObject:myFilters requiringSecureCoding:YES error:&error];
    [NSUserDefaults.standardUserDefaults setObject:encodedFilters forKey:@"filters"];
    if (error) {
        NSLog(@"Error with saving filters: %@", error);
    }
}

-(NSArray<Filter *>*)_loadFiltersData {
    NSError *error;
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:@"filters"];
    NSSet *set = [[NSSet alloc] init];
    [set setByAddingObject:[Filter class]];
    
    NSSet *classes = [[NSSet alloc] initWithArray:@[Filter.class, NSArray.class]];
    NSArray *storedFilters = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
    if (error) {
        NSLog(@"Error with loading filters: %@", error.localizedDescription);
    }
    return storedFilters != nil ? storedFilters : [[NSArray alloc] init];
}

# pragma mark Call Delegate

-(void)_updateAndSaveFilters:(new_filters_provider)getNewFilters {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
    
    pthread_mutex_lock(&strongSelf->mutex);
    strongSelf->_filters = getNewFilters(_filters);
    [self _saveFiltersData];
    [_delegate filtersDidUpdate:_filters];
    pthread_mutex_unlock(&strongSelf->mutex);
  }
}

-(void)_updateAndSaveFilters {
  [_delegate filtersDidUpdate:_filters];
  [self _saveFiltersData];
}

@end
