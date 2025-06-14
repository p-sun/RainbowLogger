//
//  LogsManager.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-26.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"
#import "Log.h"

NS_ASSUME_NONNULL_BEGIN
@protocol LogsManagerDelegate <NSObject>

- (void)didAppendLogs;

- (void)didChangeLogs:(NSArray<Log *>*)logs;

@end

@interface LogsManager : NSObject

@property (nullable, weak) id<LogsManagerDelegate> delegate;

- (NSArray<Log *>*)getLogs;

- (NSArray<Log *>*)getNextLogs;

- (void)appendLogs:(NSArray<Log *>*)logs;

- (void)clearLogs;

@end

NS_ASSUME_NONNULL_END
