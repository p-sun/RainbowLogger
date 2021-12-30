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
                             [[FilterTypePopupInfo alloc] initWithCondition:FilterConditionColorContainingText name:@"None"],
                             [[FilterTypePopupInfo alloc] initWithCondition:FilterConditionContainsAll name:@"Must Contain"],
                             [[FilterTypePopupInfo alloc] initWithCondition:FilterConditionContainsAny name:@"Contains Any"],
                             [[FilterTypePopupInfo alloc] initWithCondition:FilterConditionNotContains name:@"Not Contains"],
                             nil];
    colorPopupInfosArray = [NSArray arrayWithObjects:
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor clearColor] name:@""],
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:164 green:4 blue:199] name:@""], // Purple
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:254 green:0 blue:212] name:@""], // Pink
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:237 green:55 blue:36] name:@""], // Red
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:250 green:157 blue:0] name:@""], // Orange
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:255 green:254 blue:1] name:@""], // Yellow
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:78 green:237 blue:146] name:@""], // Mint
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:96 green:186 blue:71] name:@""], // Green
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:40 green:181 blue:181] name:@""], // Aqua
                            [[FilterColorPopupInfo alloc] initWithColor:[NSColor NSColorFrom255Red:59 green:206 blue:255] name:@""], // Sky Blue
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

- (instancetype)initWithCondition:(FilterCondition)condition text:(NSString *)text colorTag:(NSUInteger)colorTag isEnabled:(BOOL)isEnabled {
  self = [super init];
  if (self) {
    _condition = condition;
    _text = text;
    _colorTag = colorTag;
    _isEnabled = isEnabled;
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.condition] forKey:@"condition"];
  [encoder encodeObject:self.text forKey:@"text"];
  [encoder encodeObject:self.replacementText forKey:@"replacementText"];
  [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.colorTag] forKey:@"colorTag"];
  [encoder encodeObject:[NSNumber numberWithBool:self.isRegex] forKey:@"isRegex"];
  [encoder encodeObject:[NSNumber numberWithBool:self.isEnabled] forKey:@"isEnabled"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]) {
    self.condition = [[decoder decodeObjectForKey:@"condition"] unsignedIntegerValue];
    self.text = [decoder decodeObjectForKey:@"text"];
    self.replacementText = [decoder decodeObjectForKey:@"replacementText"];
    self.colorTag = [[decoder decodeObjectForKey:@"colorTag"] unsignedIntegerValue];
    self.isRegex = [[decoder decodeObjectForKey:@"isRegex"] unsignedIntegerValue];
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

- (instancetype)initWithCondition:(FilterCondition)type name:(NSString*)name
{
  self = [super init];
  if (self) {
    self.type = type;
    self.name = name;
  }
  return self;
}

@end
