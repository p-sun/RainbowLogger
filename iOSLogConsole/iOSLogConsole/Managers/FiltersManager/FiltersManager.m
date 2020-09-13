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
        _filters = [[NSArray alloc] init];
    }
    return self;
}
- (void)clearFilters {
    _filters = [[NSArray alloc] init];
}

- (void)appendFilter:(Filter *)filter {
    _filters = [_filters arrayByAddingObject:filter];
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
}

@end
