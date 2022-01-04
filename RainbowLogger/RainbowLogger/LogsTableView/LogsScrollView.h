//
//  LogsScrollView.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-27.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogsScrollViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogsScrollView : NSScrollView

@property (nullable, weak) id<LogsScrollViewDelegate> scrollDelegate;

@end

NS_ASSUME_NONNULL_END
