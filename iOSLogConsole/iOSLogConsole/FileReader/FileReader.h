//
//  FileReader.h
//  LineReader
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FileReaderDelegate <NSObject>

-(void)fileReaderDidReadLine:(NSString*)line;

@end

@interface FileReader: NSObject {
    NSString* filePath;                /**< File path. */
    NSFileHandle* fileHandle;            /**< File handle. */
    unsigned long long currentOffset;        /**< Current offset is needed for forwards reading. */
    unsigned long long totalFileLength;        /**< Total number of bytes in file. */
    NSString* lineDelimiter;        /**< Character for line break or page break. */
    NSUInteger m_chunkSize;            /**< Standard block size. */
    BOOL isReading;
    dispatch_queue_t fileReaderQueue;
}

@property (nullable, weak) id<FileReaderDelegate> delegate;

- (id)initWithFilePath:(NSString*)path;
- (NSString*)readLine;
- (NSString*)readTrimmedLine;

@end

NS_ASSUME_NONNULL_END
