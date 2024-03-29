//
//  FiltersManager.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"
#import "FiltersData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FiltersManagerDelegate <NSObject>

-(void)filtersDidUpdate: (NSArray<Filter *>*) filters;

@end

@interface FiltersManager : NSObject <FiltersDataDelegate>

@property (nullable, weak) id<FiltersManagerDelegate> delegate;

- (NSArray<Filter *>*)getFilters;

- (NSAttributedString *)getFiltersSummary;

- (void)clearFilters;

- (void)appendFilter:(Filter *)filter;

- (void)insertAtBeginningFilters:(NSArray<Filter *> *)filters;

- (void)toggleRegexForFilterAtIndex:(NSInteger)index;

- (void)deleteFiltersAtIndexes:(NSIndexSet*)indexes;

- (void)changeFilter:(Filter *)filter atIndex:(NSInteger)index;

- (void)moveFilterFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

NS_ASSUME_NONNULL_END
