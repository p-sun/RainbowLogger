//
//  FileReader.m
//  iOSLogConsole

#import "FileReader.h"
#import "NSDataExtensions.h"

/**
    A file reader.
    Files can be read forwards or backwards by calling the
    corresponding function multiple times.
 */
@implementation FileReader

- (void)dealloc{
    m_fileHandle = nil;
}

/**
    Initialized a file reader object.
    @param filePath A file path.
    @returns An initialized FileReader object or nil if the object could not be created.
 */
- (id)initWithFilePath:(NSString*)filePath {

    self = [super init];
    if (self != nil) {
        if (!filePath || [filePath length] <= 0) {
            return nil;
        }
        m_fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        if (m_fileHandle == nil) {
            return nil;
        }
        // TODO: How can I use NSLineSeparatorCharacter instead of \n here?
        m_lineDelimiter = @"\n";
        m_filePath = filePath;
        m_currentOffset = 0ULL;
        m_chunkSize = 10;
        [m_fileHandle seekToEndOfFile];
        m_totalFileLength = [m_fileHandle offsetInFile];        
        // NSLog(@"%qu characters in %@", m_totalFileLength, [filePath lastPathComponent]); /* DEBUG LOG */
    }
    return self;
}

/**
    Reads the file forwards.
    Empty lines are not returned.
    @returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readLine {

    // TODO MOVE THIS Out
    [m_fileHandle seekToEndOfFile];
    m_totalFileLength = [m_fileHandle offsetInFile];
    
    
    if (m_totalFileLength == 0 || m_currentOffset >= m_totalFileLength) {
        return nil;
    }
    
    NSData* newLineData = [m_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    [m_fileHandle seekToFileOffset:m_currentOffset];
    NSMutableData* currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    
    while (shouldReadMore) {
        if (m_currentOffset >= m_totalFileLength) {
            break;
        }
        NSData* chunk = [m_fileHandle readDataOfLength:m_chunkSize]; // always length = 10
        // Find the location and length of the next line delimiter.
        NSRange newLineRange = [chunk rangeOfData:newLineData];
        if (newLineRange.location != NSNotFound) {
            // Include the length so we can include the delimiter in the string.
            NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
            chunk = [chunk subdataWithRange:subDataRange];
            shouldReadMore = NO;
        }
        [currentData appendData:chunk];
        m_currentOffset += [chunk length];
    }

    NSString* line = [currentData stringValueWithEncoding:NSUTF8StringEncoding];
    // finished with data
    currentData = nil;
    return line;
}

/**
    Reads the file forwards while trimming white spaces.
    @returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readTrimmedLine {
    
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/**
    Reads the file forwards using a block object.
 */
- (void)enumerateLinesUsingBlock:(void(^)(NSString*))block {
    NSString* line = nil;
    while ((line = [self readLine])) {
        block(line);
    }
}

@end
