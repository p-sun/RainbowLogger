//
//  FileStreamer.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileStreamer : NSObject <NSStreamDelegate>

@property NSInputStream *inputStream;
@property NSMutableData *data;
@property NSInteger *bytesRead;
@property NSArray<NSString*> *lines;

-(void)openFileWithFileAtPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
