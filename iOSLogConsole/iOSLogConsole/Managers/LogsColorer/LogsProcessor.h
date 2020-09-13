//
//  LogsColorer.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-09-13.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Filter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogsProcessor: NSObject

+ (NSAttributedString *)coloredLinesFromLogs:(NSArray<NSString *>*)logs filteredBy:(NSArray<Filter *>*)filters;

@end

NS_ASSUME_NONNULL_END
