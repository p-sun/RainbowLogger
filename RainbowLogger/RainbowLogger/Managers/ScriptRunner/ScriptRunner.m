//
//  ScriptRunner.m
//  RainbowLogger
//  https://stackoverflow.com/questions/3707427/how-to-read-data-from-nsfilehandle-line-by-line

#import "ScriptRunner.h"
#import "NSDataExtensions.h"

/**
 Takes an NSString Command Line script, and runs it.
 */
@implementation ScriptRunner {
  NSTask *task_;
  NSFileHandle* fileHandle_;
  dispatch_queue_t fileReaderQueue_;
  BOOL isReadingFile_;
  NSString *lastLine_;
}

- (void)dealloc {
  [self stopScript];
}

/**
 Initialized a file reader object.
 @returns An initialized ScriptRunner object or nil if the object could not be created.
 */
- (id)init {
  self = [super init];
  if (self != nil) {
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1);
    fileReaderQueue_ = dispatch_queue_create("scriptRunnerQueue", qos);
  }
  
  [self _readLines];
  
  [NSTimer scheduledTimerWithTimeInterval:0.05
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
  
  // Make this all single string so it's easy to filter out
  [self.delegate scriptRunnerDidReadLines:@[[[
    @"-------------------------------------------------\nCurrent Script:\n"
    stringByAppendingString:script] stringByAppendingString:@"\n\nRunning Script..."
  ]]];
  NSError *error;
  [task launchAndReturnError:&error];
  
  if (error) {
    NSLog(@"(PAIGE) Error %@", error);
  } else {
    task_ = task;
  }
}

- (BOOL)isScriptRunning {
  return task_ && [task_ isRunning];
}

- (void)stopScript {
  if ([self isScriptRunning]) {
    [task_ terminate];
    task_ = nil;
    fileHandle_ = nil;
  }
}

-(void)_onTick:(NSTimer *)timer {
  [self _readLines];
}

/*
 Get data from file an arbitary # of times before batching new lines to the delegate.
 
 Useful for when there are a lot of logs in the file.
 If maxDataCount is too low, logs displayed may lag behind logs in the file.
 If maxDataCount is too high, logs displayed may stutter as each new chunk logs is too big to process.
 
 Manual testing to output a lot of logs for "Edit Script":
 ```
 function echoLogs {
     for (( c=1; c<=100000; c++ ))
        do
           echo "Welcome $c times"
        done
 }
 echoLogs
 ```
 **/
-(void)_readLines {
  __weak __typeof__(self) weakSelf = self;
  if (isReadingFile_) {
    return;
  }
  dispatch_async(fileReaderQueue_, ^{
    __strong __typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    strongSelf->isReadingFile_ = YES;
    
    int dataCount = 0;
    int maxDataCount = 20;
    
    NSData *data = [strongSelf->fileHandle_ availableData];
    NSMutableArray *allLines = [[NSMutableArray alloc] init];

    while (data.length > 0) {
      NSString *longString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      if (!longString) {
        return;
      }
      NSArray *newLines = [strongSelf _parseLinesFromString:longString];
      [allLines addObjectsFromArray:newLines];
      if (dataCount < maxDataCount) {
        dataCount++;
        data = [strongSelf->fileHandle_ availableData];
      } else {
        data = [[NSData alloc] init];
      }
    }
    strongSelf->isReadingFile_ = NO;

    if (allLines.count > 0) {
      [strongSelf.delegate scriptRunnerDidReadLines:allLines];
    }
  });
}

- (NSArray*)_parseLinesFromString:(NSString *)concatenatedLines {
  NSString *newConcatenatedLines = lastLine_ ? [lastLine_ stringByAppendingString:concatenatedLines] : concatenatedLines;
  NSArray *linesArray = [newConcatenatedLines componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
  if (linesArray.count > 0) {
    // The last object is often half a line, so append it to the beginning of the next concatenatedLines
    lastLine_ = linesArray.lastObject;
    NSArray *removingLast = [linesArray subarrayWithRange:NSMakeRange(0, linesArray.count - 1)];
    return removingLast;
  }
  return nil;
}

@end
