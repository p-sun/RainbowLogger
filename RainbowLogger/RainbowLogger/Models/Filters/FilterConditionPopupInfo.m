//
//  FilterConditionPopupInfo.m
//  RainbowLogger
//
//  Created by Paige Sun on 12/29/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterCondition.h"
#import "FilterConditionPopupInfo.h"

static NSArray<FilterConditionPopupInfo *> *conditionPopupInfosArray;

@implementation FilterConditionPopupInfo

+(void)initialize {
  if (self == [FilterConditionPopupInfo class]) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i< FilterConditionSize; i++) {
      FilterCondition cond = i;
      NSString *name = [FilterConditionPopupInfo nameForCondition: cond];
      [array addObject:[[FilterConditionPopupInfo alloc] initWithCondition:cond name:name]];
    }
    conditionPopupInfosArray = array;
  }
}

+(NSString*)nameForCondition:(FilterCondition)condition {
  switch (condition) {
    case FilterConditionMustContain:
      return @"[and ] Contain";
    case FilterConditionMustNotContain:
      return @"[and ] Not Contain";
    case FilterConditionContainsAny:
      return @"[or  ] Contain";
    case FilterConditionContainsOnly:
      return @"[only] Contain";
    case FilterConditionColorContainingText:
      return @" ";
    case FilterConditionSize:
      NSAssert(NO, @"(PAIGE) FilterConditionSize should be used for enum size only");
      return @"";
  }
}

- (instancetype)initWithCondition:(FilterCondition)condition name:(NSString*)name
{
  self = [super init];
  if (self) {
    self.condition = condition;
    self.name = name;
  }
  return self;
}

+ (NSArray*)conditionPopupInfos {
  return conditionPopupInfosArray;
}

@end
