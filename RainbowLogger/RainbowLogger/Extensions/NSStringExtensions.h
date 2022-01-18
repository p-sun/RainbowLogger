//
//  NSStringExtensions.h
//  RainbowLogger
//
//  Created by Paige Sun on 1/17/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//
//#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Additions)

- (void)appendString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
