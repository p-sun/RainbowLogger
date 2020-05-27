//
//  FiltersTableView.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FiltersTableViewDelegate <NSObject>

- (void)didDeleteFilterAtIndex:(NSInteger)index;
- (void)didChangeFilter:(Filter *)filter atIndex:(NSInteger)index;
@end

@interface FiltersTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, readonly) BOOL didSetupTable;
@property (nonatomic, readonly) NSInteger columnsCount;
@property (nonatomic, readonly, copy) NSArray<NSString *> *columnTitles;
@property (nonatomic, readwrite) NSArray *filters;

@property (nullable, weak) id<FiltersTableViewDelegate> filtersDelegate;

- (void)setupTable;

@end

NS_ASSUME_NONNULL_END
