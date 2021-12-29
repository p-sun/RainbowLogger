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
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeColorContainingText name:@"Color"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeColorContainingTextRegex name:@"Color with Regex"],
                                 
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAll name:@"Filter - Contains All"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAny name:@"Filter - Contains Any"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeNotContains name:@"Filter - Not contains"],
                                 
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAllRegex name:@"Filter with Regex - Contains All"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAnyRegex name:@"Filter with Regex - Contains Any"],
                                 [[FilterTypePopupInfo alloc] initWithType:FilterByTypeNotContainsRegex name:@"Filter with Regex - Not contains"],
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

- (instancetype)initWithType:(FilterByType)type text:(NSString *)text colorTag:(NSUInteger)colorTag isEnabled:(BOOL)isEnabled {
    self = [super init];
    if (self) {
        _type = type;
        _text = text;
        _colorTag = colorTag;
        _isEnabled = isEnabled;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.type] forKey:@"type"];
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.colorTag] forKey:@"colorTag"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isEnabled] forKey:@"isEnabled"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.type = [[decoder decodeObjectForKey:@"type"] unsignedIntegerValue];
        self.text = [decoder decodeObjectForKey:@"text"];
        self.colorTag = [[decoder decodeObjectForKey:@"colorTag"] unsignedIntegerValue];
        self.isEnabled = [[decoder decodeObjectForKey:@"isEnabled"] unsignedIntegerValue];
    }
    return self;
}

+ (NSArray*)filterPopupInfos {
    return filterPopupInfosArray;
}

+ (NSArray*)colorPopupInfos {
    return colorPopupInfosArray;
}

+ (BOOL)supportsSecureCoding {
    return YES;
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
