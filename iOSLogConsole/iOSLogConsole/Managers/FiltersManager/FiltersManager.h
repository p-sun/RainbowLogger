//
//  FiltersManager.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FiltersManagerDelegate <NSObject>

-(void)filtersDidUpdate: (NSArray<Filter *>*) filters;

@end

@interface FiltersManager : NSObject

@property (nullable, weak) id<FiltersManagerDelegate> delegate;

- (NSArray<Filter *>*)getFilters;

- (void)clearFilters;

- (void)appendFilter:(Filter *)filter;

- (void)deleteFilterAtIndex:(NSInteger)index;

- (void)replaceFilter:(Filter *)filter atIndex:(NSInteger)index;

- (void)moveFilterFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

NS_ASSUME_NONNULL_END
