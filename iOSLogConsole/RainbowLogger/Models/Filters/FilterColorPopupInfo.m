//
//  FilterColor.m
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterColorPopupInfo.h"
#import "NSColorExtensions.h"
#import <Cocoa/Cocoa.h>

static NSArray<FilterColorPopupInfo *> *colorPopupInfosArray;

@implementation FilterColorPopupInfo

+(void)initialize {
  if (self == [FilterColorPopupInfo class]) {
    colorPopupInfosArray = [NSArray arrayWithObjects:
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor clearColor] name:@""],
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:164 green:4 blue:199] name:@""], // Purple
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:254 green:0 blue:212] name:@""], // Pink
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:237 green:55 blue:36] name:@""], // Red
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:250 green:157 blue:0] name:@""], // Orange
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:255 green:254 blue:1] name:@""], // Yellow
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:78 green:237 blue:146] name:@""], // Mint
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:6 green:140 blue:28] name:@""], // Green
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:0 green:199 blue:196] name:@""], // Aqua
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:110 green:240 blue:255] name:@""], // Sky Blue
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:0 green:111 blue:255] name:@""], // Medium Blue
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:35 green:19 blue:158] name:@""], // Navy Blue
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:95 green:76 blue:237] name:@""], // Blue-Purple
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:176 green:156 blue:255] name:@""], // Lavender
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor whiteColor] name:@""],
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:150 green:150 blue:150] name:@""], // Light Gray
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:89 green:89 blue:89] name:@""], // Medium Gray
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:41 green:41 blue:41] name:@""], // Dark Gray
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:203 green:103 blue:13] name:@""], // Brown
                            nil];
  }
}

+ (NSArray*)colorPopupInfos {
  return colorPopupInfosArray;
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
