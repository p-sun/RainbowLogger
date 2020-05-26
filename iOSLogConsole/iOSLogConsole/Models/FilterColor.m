//
//  FilterColor.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterColor.h"
#import <Cocoa/Cocoa.h>

@implementation FilterColor

+(NSArray*)allColors {
    return [NSArray arrayWithObjects:
            [[FilterColor alloc] initWithColor:[NSColor clearColor] name:@""],
            [[FilterColor alloc] initWithColor:[NSColor greenColor] name:@"Green"],
            [[FilterColor alloc] initWithColor:[NSColor blueColor] name:@"Blue"],
            [[FilterColor alloc] initWithColor:[NSColor yellowColor] name:@"Yellow"],
            nil];
}

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
