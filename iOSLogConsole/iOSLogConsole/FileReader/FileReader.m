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
@implementation FileReader {
  NSTask *task_;
  NSFileHandle* fileHandle_;
  dispatch_queue_t fileReaderQueue_;
  NSString *lastLine_;
}

- (void)dealloc {
  [task_ terminate];
  fileHandle_ = nil;
}

/**
 Initialized a file reader object.
 @returns An initialized FileReader object or nil if the object could not be created.
 */
- (id)init {
  self = [super init];
  if (self != nil) {
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -1);
    fileReaderQueue_ = dispatch_queue_create("fileReaderQueue", qos);
  }
  
  [self _readLines];
  
  [NSTimer scheduledTimerWithTimeInterval:0.3
                                   target:self
                                 selector:@selector(_onTick:)
                                 userInfo:nil
                                  repeats:YES];
  
  return self;
}


- (void)runScript:(NSString *)script {
  [task_ terminate];
  
  NSTask *task = [[NSTask alloc] init];
  NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
  NSString *shellString = [environmentDict objectForKey:@"SHELL"];
  [task setLaunchPath: shellString];
  task.arguments = @[@"-l", @"-c", script];

  NSPipe *p = [NSPipe pipe];
  [task setStandardOutput:p];
  fileHandle_ = [p fileHandleForReading];
  [fileHandle_ waitForDataInBackgroundAndNotify];
  NSError *error;
  [task launchAndReturnError:&error];
  if (error) {
    NSLog(@"(PAIGE) Error %@", error);
  }
  
  task_ = task;
}

-(void)_onTick:(NSTimer *)timer {
  [self _readLines];
}

-(void)_readLines {
  __weak __typeof__(self) weakSelf = self;
  dispatch_async(fileReaderQueue_, ^{
    __strong __typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    NSData *data = [strongSelf->fileHandle_ availableData];
    if (data.length > 0) {
      NSString *longString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      if (longString) {
        [strongSelf _parseLinesFromString:longString];
      }
    }
  });
}

- (void)_parseLinesFromString:(NSString *)concatenatedLines {
  NSString *newConcatenatedLines = lastLine_ ? [lastLine_ stringByAppendingString:concatenatedLines] : concatenatedLines;
  NSArray *linesArray = [newConcatenatedLines componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
  if (linesArray.count > 0) {
    // The last object is often half a line, so append it to the beginning of the next concatenatedLines
    lastLine_ = linesArray.lastObject;
    NSArray *removingLast = [linesArray subarrayWithRange:NSMakeRange(0, linesArray.count - 1)];
    [self.delegate fileReaderDidReadLines:removingLast];
  }
}

@end
