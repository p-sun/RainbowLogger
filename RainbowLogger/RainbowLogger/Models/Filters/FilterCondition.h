//
//  FilterCondition.h
//  RainbowLogger
//
//  Created by Paige Sun on 12/29/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//

typedef NS_ENUM(NSInteger, FilterCondition) {
  FilterConditionColorContainingText, // For coloring text only
  FilterConditionMustContain,
  FilterConditionMustNotContain,
  FilterConditionContainsAny,
  FilterConditionSize // For enum size only
};
