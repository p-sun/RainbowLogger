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

-(void)didChangeFilters:(NSArray<Filter *>*)filters;

@end

@interface FiltersManager : NSObject

@property (nonatomic, readonly) NSArray *filters;
@property (nullable, weak) id<FiltersManagerDelegate> delegate;

- (void)addFilter:(Filter *)filter;

- (void)deleteFilterAtIndex:(NSInteger)index;

- (void)setFilter:(Filter *)filter atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
