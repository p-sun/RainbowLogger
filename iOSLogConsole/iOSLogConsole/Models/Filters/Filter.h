//
//  Filter.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterColorPopupInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FilterCondition) {
  FilterConditionColorContainingText, // For coloring text only
  FilterConditionContainsAll,
  FilterConditionContainsAny,
  FilterConditionNotContains
};

@interface Filter : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, readwrite) FilterCondition condition;
@property (nonatomic, readwrite) BOOL isRegex;

@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, nullable, readwrite) NSString *replacementText;
@property (nonatomic, readwrite) NSUInteger colorTag;
@property (nonatomic, readwrite) BOOL isEnabled;

- (instancetype)initWithCondition:(FilterCondition)condition text:(NSString *)text colorTag:(NSUInteger)colorTag isEnabled:(BOOL)isEnabled;

+ (NSArray*)filterPopupInfos;
+ (NSArray*)colorPopupInfos;

@end

@interface FilterTypePopupInfo : NSObject

@property FilterCondition type;
@property NSString * _Nonnull name;

- (instancetype)initWithCondition:(FilterCondition)condition name:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
