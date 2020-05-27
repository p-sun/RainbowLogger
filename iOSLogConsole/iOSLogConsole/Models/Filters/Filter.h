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

typedef NS_ENUM(NSInteger, FilterByType) {
    FilterByTypeNoFilter,
    FilterByTypeContains,
    FilterByTypeContainsAnyOf,
    FilterByTypeNotContains,
    FilterByTypeRegex
};

@interface Filter : NSObject

@property (nonatomic, readwrite) FilterByType type;
@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, readwrite) NSInteger colorTag;
@property (nonatomic, readwrite) BOOL isEnabled;

- (instancetype)initWithType:(FilterByType)type text:(NSString *)text colorTag:(NSInteger)colorTag isEnabled:(BOOL)isEnabled;

+ (NSArray*)allFilterByTypes;
+ (NSArray*)allColors;

@end

@interface FilterTypePopupInfo : NSObject

@property FilterByType type;
@property NSString * _Nonnull name;

- (instancetype)initWithType:(FilterByType)type name:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
