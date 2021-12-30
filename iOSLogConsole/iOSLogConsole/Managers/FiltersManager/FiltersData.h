//
//  FiltersData.hpp
//  iOSLogConsole
//
//  Created by Paige Sun on 12/28/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

// Given current filters, return new filters
typedef NSArray<Filter *>* _Nonnull (^new_filters_provider)(NSArray<Filter *>* currentFilters);

@protocol FiltersDataDelegate <NSObject>

-(void)filtersDidUpdate: (NSArray<Filter *>*) filters;

@end

@interface FiltersData : NSObject

@property (nullable, weak) id<FiltersDataDelegate> delegate;

- (NSArray<Filter *>*)getFilters;

- (void)setFilters:(new_filters_provider)getNewFilters;

- (void)saveFilters;

@end

NS_ASSUME_NONNULL_END
