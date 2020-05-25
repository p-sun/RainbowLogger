//
//  FiltersTableView.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FiltersTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

- (void)setupTable;

@end

NS_ASSUME_NONNULL_END
