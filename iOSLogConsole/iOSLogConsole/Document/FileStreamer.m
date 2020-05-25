//
//  FileStreamer.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FileStreamer.h"

@implementation FileStreamer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        _lines = [[NSArray alloc] init];
    }
    return self;
}

- (void)openFileWithFileAtPath:(NSString *)path {
    _inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
          forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_inputStream setDelegate:self];
}



//- (NSString*)readLine: (NSInputStream*) inputStream {
//    uint8_t oneByte;
//    do {
//        long actuallyRead = [inputStream read: &oneByte maxLength: 1];
//        if (actuallyRead == 1) {
//            [_data appendBytes: &oneByte length: 1];
//        }
//    } while (oneByte != '\n');
//
//    return [[NSString alloc] initWithData: _data encoding: NSUTF8StringEncoding];
//}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSInteger BUFFER_LEN = 1024;
    BOOL shouldClose = NO;
    switch(eventCode) {
        case  NSStreamEventEndEncountered:
            shouldClose = YES;
            // If all data hasn't been read, fall through to the "has bytes" event
            if(![_inputStream hasBytesAvailable]) break;
        case NSStreamEventHasBytesAvailable: ; // We need a semicolon here before we can declare local variables
            uint8_t *buffer;
            NSUInteger length;
            BOOL freeBuffer = NO;
            // The stream has data. Try to get its internal buffer instead of creating one
            if(![_inputStream getBuffer:&buffer length:&length]) {
                // The stream couldn't provide its internal buffer. We have to make one ourselves
                buffer = malloc(BUFFER_LEN * sizeof(uint8_t));
                freeBuffer = YES;
                
                NSInteger result = [_inputStream read:buffer maxLength:BUFFER_LEN];
                if(result < 0) {
                    // error copying to buffer
                    break;
                }
                length = result;
            }
//            NSLog(@"*** %@", buffer);

            // length bytes of data in buffer
            if(freeBuffer) free(buffer);
            break;
        case NSStreamEventErrorOccurred:
            // some other error
            shouldClose = YES;
            break;
    }
//    if(shouldClose) {
//        [_inputStream close];
//    }
    
    
    
//    switch(eventCode) {
//    case NSStreamEventHasBytesAvailable:
//    {
//        uint8_t buf[1024];
//        NSInteger len = 0;
//        len = [(NSInputStream *)aStream read:buf maxLength:1024];
//        if(len) {
//            [_data appendBytes:(const void *)buf length:len];
//            // bytesRead is an instance variable of type NSNumber.
//            _bytesRead = _bytesRead + len;
//        } else {
//            NSLog(@"no buffer!");
//        }
//        break;
//    }
//            case NSStreamEventEndEncountered:
//            {
//                [aStream close];
//                [aStream removeFromRunLoop:[NSRunLoop currentRunLoop]
//                    forMode:NSDefaultRunLoopMode];
//                aStream = nil;
//                break;
//            }
//    }
}

@end
