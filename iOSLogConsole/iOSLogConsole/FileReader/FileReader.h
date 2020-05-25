//
//  FileReader.h
//  LineReader
//
//  Source: http://stackoverflow.com/questions/3707427#3711079

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileReader : NSObject {
    NSString*            m_filePath;                /**< File path. */
    NSFileHandle*        m_fileHandle;            /**< File handle. */
    unsigned long long    m_currentOffset;        /**< Current offset is needed for forwards reading. */
    unsigned long long    m_totalFileLength;        /**< Total number of bytes in file. */
    NSString*            m_lineDelimiter;        /**< Character for line break or page break. */
    NSUInteger            m_chunkSize;            /**< Standard block size. */
}

- (id)initWithFilePath:(NSString*)filePath;
- (NSString*)readLine;
- (NSString*)readTrimmedLine;
- (void)enumerateLinesUsingBlock:(void(^)(NSString*))block;

@end

NS_ASSUME_NONNULL_END
