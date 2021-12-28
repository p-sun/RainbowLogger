//
//  FiltersManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersManager.h"
#include <pthread.h>

@implementation FiltersManager{
  pthread_mutex_t mutex;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
      _filters = [self _loadFilters];
      pthread_mutex_init(&mutex, NULL);
    }
    return self;
}

# pragma mark Filter Modifications

- (void)clearFilters {
    __weak __typeof(self) weakSelf = self; // TODO Cleanup by moving the mutex stuff into a private func
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
      
      pthread_mutex_lock(&strongSelf->mutex);
      strongSelf->_filters = [[NSArray alloc] init];
      [strongSelf _updateAndSaveFilters];
      pthread_mutex_unlock(&strongSelf->mutex);
  }
}

- (void)appendFilter:(Filter *)filter {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
      
    pthread_mutex_lock(&strongSelf->mutex);
    strongSelf->_filters = [self->_filters arrayByAddingObject:filter];
    [strongSelf _updateAndSaveFilters];
    pthread_mutex_unlock(&strongSelf->mutex);
  }
}

- (void)deleteFilterAtIndex:(NSInteger)index {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
      
    pthread_mutex_lock(&strongSelf->mutex);
    NSMutableArray<Filter *> *newFilters = [[NSMutableArray alloc] init];
    if (index > 0) {
        NSRange frontRange = NSMakeRange(0, index);
        [newFilters addObjectsFromArray: [strongSelf->_filters subarrayWithRange: frontRange]];
    }
    if (index < strongSelf->_filters.count - 1) {
        NSInteger length = strongSelf->_filters.count - 1 - index;
        NSRange backRange = NSMakeRange(index + 1, length);
        [newFilters addObjectsFromArray: [strongSelf->_filters subarrayWithRange: backRange]];
    }
    strongSelf->_filters = newFilters;
    [strongSelf _updateAndSaveFilters];
    pthread_mutex_unlock(&strongSelf->mutex);
  }
}

- (void)replaceFilter:(Filter *)filter atIndex:(NSInteger)index {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
    
    pthread_mutex_lock(&strongSelf->mutex);

    NSMutableArray<Filter *> *newFilters = [[NSMutableArray alloc] init];
    if (index > 0) {
        NSRange frontRange = NSMakeRange(0, index);
        [newFilters addObjectsFromArray: [strongSelf->_filters subarrayWithRange: frontRange]];
    }
    [newFilters addObject:filter];
    if (index < strongSelf->_filters.count - 1) {
        NSInteger length = strongSelf->_filters.count - 1 - index;
        NSRange backRange = NSMakeRange(index + 1, length);
        [newFilters addObjectsFromArray: [strongSelf->_filters subarrayWithRange: backRange]];
    }
    strongSelf->_filters = newFilters;
    [strongSelf _updateAndSaveFilters];
    pthread_mutex_unlock(&strongSelf->mutex);
  }
}

- (void)moveFilterFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  __weak __typeof(self) weakSelf = self;
  {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) { return; }
    
    pthread_mutex_lock(&strongSelf->mutex);
 
    Filter *filterToMove = [_filters objectAtIndex:fromIndex];
    NSMutableArray<Filter *> *newFilters = [[NSMutableArray alloc] initWithArray:_filters];

    [newFilters insertObject:filterToMove atIndex:toIndex];

    if (fromIndex < toIndex) {
        [newFilters removeObjectAtIndex:fromIndex];
    } else {
        [newFilters removeObjectAtIndex:fromIndex+1];
    }

    strongSelf->_filters = newFilters;
    [strongSelf _updateAndSaveFilters];
    pthread_mutex_unlock(&strongSelf->mutex);
  }
}

# pragma mark Save and Load Filters from File

-(void)_saveFilters {
    NSError *error;
    NSArray *myFilters = _filters;
    NSData *encodedFilters = [NSKeyedArchiver archivedDataWithRootObject:myFilters requiringSecureCoding:YES error:&error];
    [NSUserDefaults.standardUserDefaults setObject:encodedFilters forKey:@"filters"];
    if (error) {
        NSLog(@"Error with saving filters: %@", error);
    }
}

-(NSArray<Filter *>*)_loadFilters {
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

-(void)_updateAndSaveFilters {
  [_delegate filtersDidUpdate:_filters];
  [self _saveFilters];
}

@end
