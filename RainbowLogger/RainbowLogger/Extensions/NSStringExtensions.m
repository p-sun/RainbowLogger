//
//  NSStringExtensions.m
//  RainbowLogger
//
//  Created by Paige Sun on 1/17/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import "NSStringExtensions.h"

@implementation NSMutableAttributedString (Additions)

- (void)appendString:(NSString *)string {
  NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string];
  [self appendAttributedString:attrString];
}

@end
