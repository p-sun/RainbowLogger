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

@interface FiltersManager : NSObject

@property (nonatomic, readonly) NSArray<Filter *>* filters;

- (void)appendFilter:(Filter *)filter;

- (void)deleteFilterAtIndex:(NSInteger)index;

- (void)replaceFilter:(Filter *)filter atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
