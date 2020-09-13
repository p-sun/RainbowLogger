//
//  LogsTextView.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-09-12.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogsScrollViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogsTextView : NSTextView

@property (nullable, weak) id<LogsScrollViewDelegate> scrollDelegate;

- (void)addAttributedLines:(NSAttributedString *)attributedLines shouldAutoscroll:(BOOL)shouldAutoscroll;

- (void)setAttributedLines:(NSAttributedString *)attributedLines shouldAutoscroll:(BOOL)shouldAutoscroll;

@end

NS_ASSUME_NONNULL_END
