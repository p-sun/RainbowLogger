//
//  FilterCondition.h
//  iOSLogConsole
//
//  Created by Paige Sun on 12/29/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//

typedef NS_ENUM(NSInteger, FilterCondition) {
  FilterConditionColorContainingText, // For coloring text only
  FilterConditionContainsAll,
  FilterConditionContainsAny,
  FilterConditionNotContains
};
