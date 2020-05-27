//
//  LogsTableView.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogsTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, readonly) BOOL didSetupTable;
@property (nonatomic, readonly) NSInteger columnsCount;
@property (nonatomic, readonly, copy) NSArray<NSString *> *columnTitles;
@property (nonatomic, readwrite, copy) NSArray<NSString *> *lines;

- (void)setupTable;

@end

NS_ASSUME_NONNULL_END
