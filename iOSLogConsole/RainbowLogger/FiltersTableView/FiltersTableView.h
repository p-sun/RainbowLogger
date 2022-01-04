//
//  FiltersTableView.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FiltersTableViewDelegate <NSObject>

- (void)didToggleRegexAtIndex:(NSInteger)index;

- (void)didDeleteFilterAtIndexes:(NSIndexSet *)indexes;

- (void)didChangeFilter:(Filter *)filter atIndex:(NSInteger)index;

- (void)didMoveFilter:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface FiltersTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

@property (nullable, weak) id<FiltersTableViewDelegate> filtersDelegate;

- (void)resizeTableWidth;

- (void)setFilters:(NSArray<Filter *>*)filters;

@end

NS_ASSUME_NONNULL_END
