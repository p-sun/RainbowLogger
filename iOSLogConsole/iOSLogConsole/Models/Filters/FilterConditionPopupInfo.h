//
//  FilterCondition.m
//  iOSLogConsole
//
//  Created by Paige Sun on 12/29/21.
//  Copyright © 2021 Paige Sun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FilterCondition.h"

NS_ASSUME_NONNULL_BEGIN

@interface FilterConditionPopupInfo : NSObject

@property FilterCondition type;
@property NSString * _Nonnull name;

+ (NSArray*)conditionPopupInfos;

- (instancetype)initWithCondition:(FilterCondition)condition name:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
