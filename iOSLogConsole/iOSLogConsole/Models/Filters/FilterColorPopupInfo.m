//
//  FilterColor.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterColorPopupInfo.h"
#import <Cocoa/Cocoa.h>

@implementation FilterColorPopupInfo

- (instancetype)initWithColor:(NSColor * _Nonnull)color name:(NSString*)name
{
    self = [super init];
    if (self) {
        self.color = color;
        self.name = name;
    }
    return self;
}

@end
