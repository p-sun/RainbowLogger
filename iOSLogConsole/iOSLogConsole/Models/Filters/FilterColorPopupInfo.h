//
//  FilterColor.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterColorPopupInfo : NSObject
    @property NSColor * _Nonnull color;
    @property NSString * _Nonnull name;

- (instancetype)initWithColor:(NSColor * _Nonnull)color name:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
