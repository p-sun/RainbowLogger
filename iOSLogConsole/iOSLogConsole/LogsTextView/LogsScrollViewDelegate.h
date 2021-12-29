//
//  LogsScrollViewDelegate.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-09-13.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

@protocol LogsScrollViewDelegate <NSObject>

- (void)logsScrollViewDidScrollUp;

- (void)logsScrollViewDidScrollDown;

@end
