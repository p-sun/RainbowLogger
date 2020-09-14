//
//  LogsTextView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-09-12.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "LogsTextView.h"
#import <Foundation/Foundation.h>

@implementation LogsTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Setting richText allows the text colors to be copied to other editors
    self.richText = true;
}

- (void)addAttributedLines:(NSAttributedString *)attributedLines shouldAutoscroll:(BOOL)shouldAutoscroll {
    
    __weak __typeof__(self) weakSelf = self;
    [self _updateTextViewAndShouldAutoscroll:shouldAutoscroll actionBlock:^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf.textStorage appendAttributedString:attributedLines];
    }];
}

- (void)setAttributedLines:(NSAttributedString *)attributedLines shouldAutoscroll:(BOOL)shouldAutoscroll {
    
    __weak __typeof__(self) weakSelf = self;
    [self _updateTextViewAndShouldAutoscroll:shouldAutoscroll actionBlock:^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf.textStorage setAttributedString:attributedLines];
    }];
}

- (void)_updateTextViewAndShouldAutoscroll:(BOOL)shouldAutoscroll actionBlock:(void (^)(void))actionBlock {
    
    __weak __typeof__(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        actionBlock();
        
        if (shouldAutoscroll) {
            [strongSelf scrollToEndOfDocument:nil];
        }
    });
}

- (void)scrollWheel:(NSEvent *)event {
    [super scrollWheel:event];
    
    if (event.deltaY > 0) {
        [_scrollDelegate logsScrollViewDidScrollUp];
    } else {
        [_scrollDelegate logsScrollViewDidScrollDown];
    }
}

@end
