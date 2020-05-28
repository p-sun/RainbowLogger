//
//  Filter.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "Filter.h"
#import "NSColorExtensions.h"

static NSArray<FilterTypePopupInfo *> *filterPopupInfosArray;
static NSArray<FilterColorPopupInfo *> *colorPopupInfosArray;

@implementation Filter

+(void)initialize {
    if (self == [Filter class]) {
        filterPopupInfosArray = [NSArray arrayWithObjects:
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeNoFilter name:@""],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeMustContain name:@"Must contain"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsOneOrMoreOf name:@"Contains at least one of"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAnyOf name:@"Contains any of"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeMustNotContain name:@"Must not contain"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeRegex name:@"Must contains regex"],
                                 nil];
        ;
        colorPopupInfosArray = [NSArray arrayWithObjects:
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor clearColor] name:@""],
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:47 green:218 blue:120] name:@""], // Mint
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:0 green:111 blue:255] name:@""], // Medium Blue
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:255 green:254 blue:1] name:@""], // Yellow
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:250 green:157 blue:0] name:@""], // Orange
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:237 green:55 blue:36] name:@""], // Red
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:254 green:0 blue:212] name:@""], // Pink
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:96 green:186 blue:71] name:@""], // Green
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:164 green:4 blue:199] name:@""], // Purple
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:20 green:199 blue:222] name:@""], // Sky Blue
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:176 green:156 blue:255] name:@""], // Lavender
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:203 green:103 blue:13] name:@""], // Brown
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:18 green:5 blue:119] name:@""], // Navy Blue
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor whiteColor] name:@""],
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:150 green:150 blue:150] name:@""], // Light Gray
                                [[FilterColorPopupInfo alloc] initWithColor:[NSColor blackColor] name:@""],
                                
                                nil];
    }
}

- (instancetype)initWithType:(FilterByType)type text:(NSString *)text colorTag:(NSInteger)colorTag isEnabled:(BOOL)isEnabled {
    self = [super init];
    if (self) {
        _type = type;
        _text = text;
        _colorTag = colorTag;
        _isEnabled = isEnabled;
    }
    return self;
}

+ (NSArray*)filterPopupInfos {
    return filterPopupInfosArray;
}

+ (NSArray*)colorPopupInfos {
    return colorPopupInfosArray;
}

@end

@implementation FilterTypePopupInfo

- (instancetype)initWithType:(FilterByType)type name:(NSString*)name
{
    self = [super init];
    if (self) {
        self.type = type;
        self.name = name;
    }
    return self;
}

@end
