//
//  Filter.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "Filter.h"

@implementation Filter

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

+ (NSArray*)allFilterByTypes {
  return [NSArray arrayWithObjects:
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeNoFilter name:@""],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContains name:@"Contains"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAnyOf name:@"Contains Any Of"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeNotContains name:@"Does Not Contain"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeRegex name:@"Contains Regex"],
  nil];
}

+ (NSArray*)allColors {
    return [NSArray arrayWithObjects:
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor clearColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor greenColor] name:@"Green"],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor blueColor] name:@"Blue"],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor yellowColor] name:@"Yellow"],
            nil];
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
