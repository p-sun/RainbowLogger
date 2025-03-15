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
  // Run script with task
  NSTask *_task;
  
  // File Reading
  NSThread *_fileReadingThread;
  NSFileHandle* _outputHandle;
  NSString *_lastLine;
}

#pragma mark - Init & Dealloc

/**
 Initialized a file reader object.
 @returns An initialized ScriptRunner object or nil if the object could not be created.
 */
- (id)init {
  self = [super init];
  if (self != nil) {
    _fileReadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(runBufferReadThread) object:nil];
    [_fileReadingThread setName:@"FileReadThread"];
    [_fileReadingThread start];
  }
  return self;
}

- (void)dealloc {
  [self stopScript];
}

#pragma mark - Public APIs

- (void)runScript:(NSString *)script {
  [self performSelector:@selector(runScriptOnThread:) onThread:_fileReadingThread withObject:script waitUntilDone:NO];
}

- (void)stopScript {
  [self performSelector:@selector(stopScriptOnThread) onThread:_fileReadingThread withObject:nil waitUntilDone:YES];
}

- (BOOL)isScriptRunning {
  return _task != nil;
}

- (void)runBufferReadThread
{
  // onTick is supposed to do nothing. It's only purpose is to keep the NSRunLoop alive.
  NSTimer *_linesBufferTimer = [NSTimer timerWithTimeInterval:100000 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:_linesBufferTimer forMode:NSRunLoopCommonModes];
  [[NSRunLoop currentRunLoop] run];
}

#pragma mark - Private Threading & Script Management

-(void)onTick:(NSTimer *)timer {
}

- (void)stopScriptOnThread {
  [_task terminate];
  [[NSNotificationCenter defaultCenter] removeObserver:_outputHandle];
  [_outputHandle closeFile];
  _outputHandle = nil;
  _lastLine = nil;
  _task = nil;
}

- (void)runScriptOnThread:(NSString *)script {
  [self stopScript];
  
  NSTask *task = [[NSTask alloc] init];
  NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
  NSString *shellString = [environmentDict objectForKey:@"SHELL"];
  [task setLaunchPath: shellString];
  task.arguments = @[@"-l", @"-c", script];

  NSPipe *outputPipe = [NSPipe pipe];
  [task setStandardOutput:outputPipe];
  [task setStandardError:outputPipe];
  _task = task;

  _outputHandle = [outputPipe fileHandleForReading];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readLogsFromFileOnThread:) name:NSFileHandleDataAvailableNotification object:_outputHandle];
  
  // Need to be called from a thread with a RunLoop
  [_outputHandle waitForDataInBackgroundAndNotify];
  
  // Make this all single string so it's easy to filter out
  [self.delegate scriptRunnerDidReadLines:@[[[
    @"-------------------------------------------------\nCurrent Script:\n"
    stringByAppendingString:script] stringByAppendingString:@"\n\nRunning Script...\n"
  ]]];
  
  NSError *error;
  [task launchAndReturnError:&error];
  
  if (error) {
    [self.delegate scriptRunnerDidReadLines:@[[
      @"Error with script: " stringByAppendingString:error.localizedDescription]]];
    [self stopScript];
  } else {
    [_delegate scriptRunnerDidUpdateScriptStatus];
  }
}

#pragma mark - Reading Logs from File

/*
 Read lines from file, and write to LinesBuffer
 --------
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
- (void)readLogsFromFileOnThread:(NSNotification *)aNotification {
  // Blocks thread until there is data
  NSData *data = [_outputHandle availableData];
  
  // When there is no more data left to read in the file,
  // and the NSTask has finished, append "Script Finished" to the logs.
  if (data.length == 0) {
    if (_task && ![_task isRunning]) {
      [_delegate scriptRunnerDidReadLines:@[@"\nScript Finished.\n"]];
      [self stopScript];
    }
  }
  
  NSArray *lines = [self getLinesFromData:data];
  if (lines && lines.count > 0) {
    [_delegate scriptRunnerDidReadLines:[lines copy]];
  }
  
  // Calls NSFileHandleDataAvailableNotification when there is more data
  [_outputHandle waitForDataInBackgroundAndNotify];
}

-(NSArray *)getLinesFromData:(NSData *)data {
  NSString *longString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  if (!longString) {
    NSLog(@"(PAIGE) ERROR: Could not get UTF8 string from data");
    return nil;
  }
  return [self parseLinesFromString:longString];
}

- (NSArray *)parseLinesFromString:(NSString *)concatenatedLines {
  NSString *newConcatenatedLines = _lastLine ? [_lastLine stringByAppendingString:concatenatedLines] : concatenatedLines;
  NSArray *linesArray = [newConcatenatedLines componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
  if (linesArray.count > 0) {
    // The last object is often half a line, so append it to the beginning of the next concatenatedLines
    _lastLine = linesArray.lastObject;
    NSArray *removingLast = [linesArray subarrayWithRange:NSMakeRange(0, linesArray.count - 1)];
    return removingLast;
  }
  return nil;
}

@end
