//
//  FiltersData.cpp
//  iOSLogConsole
//
//  Created by Paige Sun on 12/28/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//

#include "FiltersData.h"
#include <pthread.h>

@implementation FiltersData{
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

- (NSArray<Filter *>*)getFilters {
  return _filters;
}

# pragma mark UpdateFilters Delegate

-(void)setFilters:(new_filters_provider)getNewFilters {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
    
    pthread_mutex_lock(&strongSelf->mutex);
    strongSelf->_filters = getNewFilters(_filters);
    [_delegate filtersDidUpdate:_filters];
    [self _saveFiltersData];
    pthread_mutex_unlock(&strongSelf->mutex);
  }
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

@end
