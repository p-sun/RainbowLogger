//
//  Filter.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "Filter.h"
#import "NSColorExtensions.h"

@implementation Filter

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

+ (BOOL)supportsSecureCoding {
  return YES;
}

@end
