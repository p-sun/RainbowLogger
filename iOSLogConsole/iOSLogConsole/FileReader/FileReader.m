//
//  FileReader.m
//  iOSLogConsole
//  https://stackoverflow.com/questions/3707427/how-to-read-data-from-nsfilehandle-line-by-line

#import "FileReader.h"
#import "NSDataExtensions.h"

/**
    A file reader.
    Files can be read forwards or backwards by calling the
    corresponding function multiple times.
 */
@implementation FileReader{
    NSTask *task_;
    NSFileHandle* fileHandle_;
    dispatch_queue_t fileReaderQueue_;
}

- (void)dealloc {
    fileHandle_ = nil;
}

/**
    Initialized a file reader object.
    @returns An initialized FileReader object or nil if the object could not be created.
 */
- (id)init {
    self = [super init];
    if (self != nil) {
        NSTask *task = [[NSTask alloc] init];
        NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
        NSString *shellString = [environmentDict objectForKey:@"SHELL"];
        [task setLaunchPath: shellString];
        task.arguments = @[@"-l",
                           @"-c",
                           @"xcrun simctl spawn booted log stream --level=debug --style=compact --predicate 'eventMessage contains \"****\"';"];
        // Other args: --process=AppName
        
        NSPipe *p = [NSPipe pipe];
        [task setStandardOutput:p];
        fileHandle_ = [p fileHandleForReading];
        [fileHandle_ waitForDataInBackgroundAndNotify];
        [task launch];

        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -1);
        fileReaderQueue_ = dispatch_queue_create("fileReaderQueue", qos);
    }
    
    [self readLines];

    [NSTimer scheduledTimerWithTimeInterval:0.3
    target:self
    selector:@selector(onTick:)
    userInfo:nil
    repeats:YES];
    
    return self;
}

-(void)onTick:(NSTimer *)timer {
    [self readLines];
}

-(void)readLines {
    NSData *data = [fileHandle_ availableData];
    if (data.length > 0) { // if data is found, re-register for more data (and print)
        NSString *longString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(fileReaderQueue_, ^{
            [weakSelf parseLinesFromString:longString];
        });
    }
}

- (void)parseLinesFromString:(NSString *)longString {
    NSArray *linesArray = [longString componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
    for (NSUInteger index = 0; index < [linesArray count] - 1; index++) {
        NSString *oneLine = linesArray[index];
        [self.delegate fileReaderDidReadLine:oneLine];
    }
    
    [fileHandle_ waitForDataInBackgroundAndNotify];
}

@end
