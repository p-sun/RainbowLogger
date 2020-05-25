//
//  DocumentReader.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "DocumentReader.h"

@implementation DocumentReader

-(void)openFileWithFilename:(const char *)filename {
    _file = fopen(filename, "r");
    [self readFile];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
    target:self
    selector:@selector(onTick:)
    userInfo:nil
    repeats:YES];
}

-(void)readFile {
    size_t length;
    char *cLine;
    _file = fopen("test.log", "r");

    while (true) {
        cLine = fgetln(_file, &length);
        if (length <= 0) {
            break;
        }
        
        char str[length+1];
        strncpy(str, cLine, length);
        str[length] = '\0';

        NSString *line = [NSString stringWithFormat:@"%s", str];
        NSLog(line);
//        % Do what you want here.
    }
}

-(void)onTick:(NSTimer *)timer {
 [self readFile];
}


@end
