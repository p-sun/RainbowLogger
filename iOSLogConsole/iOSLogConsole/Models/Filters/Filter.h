//
//  Filter.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterColor.h"

typedef NS_ENUM(NSInteger, FilterByType) {
    FilterByTypeNone,
    FilterByTypeContains,
    FilterByTypeContainsAnyOf,
    FilterByTypeRegex
};

NS_ASSUME_NONNULL_BEGIN

@interface Filter : NSObject

@property (nonatomic, readwrite) FilterByType type;
@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, readwrite) FilterColor *color;
@property (nonatomic, readwrite) BOOL isEnabled;

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
