//
//  NSColorExtensions.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSColorExtensions.h"

@implementation NSColor (Additions)

+ (NSColor*) NSColorFrom255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    
    return [NSColor colorWithCalibratedRed:red/255.0 green:green/255.0 blue:blue/255.0
                                     alpha:alpha];
}

@end
