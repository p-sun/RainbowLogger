//
//  FileReader.h
//  LineReader
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FileReaderDelegate <NSObject>

-(void)fileReaderDidReadLine:(NSString*)line;

@end

@interface FileReader: NSObject

@property (nullable, weak) id<FileReaderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
