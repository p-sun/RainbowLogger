//
//  Filter.h
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterColorPopupInfo.h"
#import "FilterCondition.h"

NS_ASSUME_NONNULL_BEGIN

// TODO make Filter a readonly struct
@interface Filter : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, readwrite) FilterCondition condition;
@property (nonatomic, readwrite) BOOL isRegex;

@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, nullable, readwrite) NSString *replacementText;
@property (nonatomic, readwrite) NSUInteger colorTag;
@property (nonatomic, readwrite) BOOL isEnabled;

- (instancetype)initWithCondition:(FilterCondition)condition text:(NSString *)text colorTag:(NSUInteger)colorTag isEnabled:(BOOL)isEnabled;
- (instancetype)initWithCondition:(FilterCondition)condition text:(NSString *)text isRegex:(BOOL)isRegex colorTag:(NSUInteger)colorTag replacementText:(nullable NSString *)replacementText isEnabled:(BOOL)isEnabled;

@end

NS_ASSUME_NONNULL_END
