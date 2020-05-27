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
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeMustContain name:@"Must contain"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsOneOrMoreOf name:@"Contains at least one of"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeContainsAnyOf name:@"Contains any of"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeMustNotContain name:@"Must not contain"],
          [[FilterTypePopupInfo alloc] initWithType:FilterByTypeRegex name:@"Must contains regex"],
  nil];
}

+ (NSArray*)allColors {
    return [NSArray arrayWithObjects:
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor clearColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor whiteColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor greenColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor blueColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor yellowColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor redColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor orangeColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor cyanColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor purpleColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor magentaColor] name:@""],
            [[FilterColorPopupInfo alloc] initWithColor:[NSColor lightGrayColor] name:@""],
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
