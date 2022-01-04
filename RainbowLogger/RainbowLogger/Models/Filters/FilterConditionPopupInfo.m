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
    conditionPopupInfosArray = [NSArray arrayWithObjects:
                                [[FilterConditionPopupInfo alloc] initWithCondition:FilterConditionColorContainingText name:@"None"],
                                [[FilterConditionPopupInfo alloc] initWithCondition:FilterConditionContainsAll name:@"Must Contain"],
                                [[FilterConditionPopupInfo alloc] initWithCondition:FilterConditionContainsAny name:@"Contains Any"],
                                [[FilterConditionPopupInfo alloc] initWithCondition:FilterConditionNotContains name:@"Not Contain"],
                                nil];
  }
}

- (instancetype)initWithCondition:(FilterCondition)type name:(NSString*)name
{
  self = [super init];
  if (self) {
    self.type = type;
    self.name = name;
  }
  return self;
}

+ (NSArray*)conditionPopupInfos {
  return conditionPopupInfosArray;
}

@end
