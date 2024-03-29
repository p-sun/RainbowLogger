//
//  LogsScrollView.m
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-27.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsScrollView.h"

@implementation LogsScrollView

- (void)scrollWheel:(NSEvent *)event {
  [super scrollWheel:event];
  if (event.deltaY > 0) {
    [_scrollDelegate logsScrollViewDidScrollUp];
  }
}

@end
