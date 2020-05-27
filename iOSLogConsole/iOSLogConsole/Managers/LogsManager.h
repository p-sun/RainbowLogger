//
//  LogsManager.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LogsManagerDelegate <NSObject>

- (void)didChangeFilteredLogs:(NSArray<NSString *>*)logs;

@end

@interface LogsManager : NSObject

@property (nonatomic, readonly, copy) NSArray<NSString *> *allLogs;
@property (nonatomic, readonly, copy) NSArray<NSString *> *filteredLogs;

@property (nullable, weak) id<LogsManagerDelegate> delegate;

- (void)addLog:(NSString*)log passingFilters:(NSArray<Filter *>*)filters;
- (void)filterLogsBy:(NSArray<Filter *>*)filters;

@end

NS_ASSUME_NONNULL_END
