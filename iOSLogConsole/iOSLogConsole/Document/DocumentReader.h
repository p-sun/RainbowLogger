//
//  DocumentReader.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocumentReader : NSObject

@property (nonatomic, readwrite) FILE *file;
@property (nonatomic, readwrite) NSString *filename;

-(void)openFileWithFilename:(const char *)filename;
-(void)readFile;

@end

NS_ASSUME_NONNULL_END
