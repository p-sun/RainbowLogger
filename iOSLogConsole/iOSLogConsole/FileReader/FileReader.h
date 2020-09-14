//
//  FileReader.h
//  LineReader
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FileReaderDelegate <NSObject>

-(void)fileReaderDidReadLines:(NSArray<NSString *>*)lines;

@end

@interface FileReader: NSObject

@property (nullable, weak) id<FileReaderDelegate> delegate;

- (void)reattachToSimulator;

@end

NS_ASSUME_NONNULL_END
