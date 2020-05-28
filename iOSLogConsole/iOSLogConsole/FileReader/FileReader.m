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
@implementation FileReader

- (void)dealloc {
    fileHandle = nil;
}

/**
    Initialized a file reader object.
    @param path A file path.
    @returns An initialized FileReader object or nil if the object could not be created.
 */
- (id)initWithFilePath:(NSString*)path {
    self = [super init];
    if (self != nil) {
        if (!path || [path length] <= 0) {
            return nil;
        }
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        if (fileHandle == nil) {
            NSLog(@"No file exist at path: %@", path);
            return nil;
        }
        lineDelimiter = @"\n";
        filePath = path;
        currentOffset = 0;
        m_chunkSize = 10;
        [fileHandle seekToEndOfFile];
        totalFileLength = [fileHandle offsetInFile];        
        // NSLog(@"%qu characters in %@", totalFileLength, [filePath lastPathComponent]); /* DEBUG LOG */
        
        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, -1);
        fileReaderQueue = dispatch_queue_create("fileReaderQueue", qos);
    }
    
    [self readLines];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4
    target:self
    selector:@selector(onTick:)
    userInfo:nil
    repeats:YES];
    
    return self;
}

-(void)onTick:(NSTimer *)timer {
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(fileReaderQueue, ^{
        [weakSelf readLines];
    });
}

-(void)readLines {
    [fileHandle seekToEndOfFile];
    totalFileLength = [fileHandle offsetInFile];

    if (isReading) {
        return;
    }
    
    isReading = true;
    NSString* line = nil;
    while ((line = [self readTrimmedLine])) {
        [self.delegate fileReaderDidReadLine:line];
    }
    isReading = false;
}

/**
    Reads the file forwards while trimming white spaces.
    @returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readTrimmedLine {
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/**
    Reads the file forwards.
    Empty lines are not returned.
    @returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readLine {
    if (totalFileLength == 0 || currentOffset >= totalFileLength) {
        currentOffset = totalFileLength;
        return nil;
    }
    
    NSData* newLineData = [lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle seekToFileOffset:currentOffset];
    NSMutableData* currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    
    while (shouldReadMore) {
        if (currentOffset >= totalFileLength) {
            break;
        }
        NSData* chunk = [fileHandle readDataOfLength:m_chunkSize]; // always length = 10
        // Find the location and length of the next line delimiter.
        NSRange newLineRange = [chunk rangeOfData:newLineData];
        if (newLineRange.location != NSNotFound) {
            // Include the length so we can include the delimiter in the string.
            NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
            chunk = [chunk subdataWithRange:subDataRange];
            shouldReadMore = NO;
        }
        [currentData appendData:chunk];
        currentOffset += [chunk length];
    }

    NSString* line = [currentData stringValueWithEncoding:NSUTF8StringEncoding];
    // finished with data
    currentData = nil;
    return line;
}

@end
