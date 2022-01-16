//
//  ScriptRunner.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScriptRunnerDelegate <NSObject>

-(void)scriptRunnerDidUpdateScriptStatus;

-(void)scriptRunnerDidReadLines:(NSArray<NSString *>*)lines;

@end

@interface ScriptRunner: NSObject

@property (nullable, weak) id<ScriptRunnerDelegate> delegate;

- (void)runScript:(NSString *)script;

- (void)stopScript;

- (BOOL)isScriptRunning;

@end

NS_ASSUME_NONNULL_END
