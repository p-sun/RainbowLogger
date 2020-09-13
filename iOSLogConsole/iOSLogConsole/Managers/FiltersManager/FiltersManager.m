//
//  FiltersManager.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FiltersManager.h"

@implementation FiltersManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filters = [self _loadFilters];
    }
    return self;
}
- (void)clearFilters {
    _filters = [[NSArray alloc] init];
    [self _saveFilters];
}

- (void)appendFilter:(Filter *)filter {
    _filters = [_filters arrayByAddingObject:filter];
    [self _saveFilters];
}

- (void)deleteFilterAtIndex:(NSInteger)index {
    NSMutableArray<Filter *> *newFilters = [[NSMutableArray alloc] init];
    if (index > 0) {
        NSRange frontRange = NSMakeRange(0, index);
        [newFilters addObjectsFromArray: [_filters subarrayWithRange: frontRange]];
    }
    if (index < _filters.count - 1) {
        NSInteger length = _filters.count - 1 - index;
        NSRange backRange = NSMakeRange(index + 1, length);
        [newFilters addObjectsFromArray: [_filters subarrayWithRange: backRange]];
    }
    _filters = newFilters;
    [self _saveFilters];
}

- (void)replaceFilter:(Filter *)filter atIndex:(NSInteger)index {
    NSMutableArray<Filter *> *newFilters = [[NSMutableArray alloc] init];
    if (index > 0) {
        NSRange frontRange = NSMakeRange(0, index);
        [newFilters addObjectsFromArray: [_filters subarrayWithRange: frontRange]];
    }
    [newFilters addObject:filter];
    if (index < _filters.count - 1) {
        NSInteger length = _filters.count - 1 - index;
        NSRange backRange = NSMakeRange(index + 1, length);
        [newFilters addObjectsFromArray: [_filters subarrayWithRange: backRange]];
    }
    _filters = newFilters;
    [self _saveFilters];
}

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

@end
