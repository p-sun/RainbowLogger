//
//  NSViewExtensions.h
//  RainbowLogger
//
//  Created by Paige Sun on 1/3/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (Additions)

+ (id)loadWithNibNamed:(NSString *)nibNamed class:(Class)loadClass owner:(id)owner;

- (void)constrainToSuperview;

@end

NS_ASSUME_NONNULL_END
