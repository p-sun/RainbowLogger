//
//  EditScriptView.h
//  RainbowLogger
//
//  Created by Paige Sun on 1/3/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EditScriptViewDelegate <NSObject>

-(void)editScriptViewDidPressClose;
-(void)editScriptViewDidPressRunScript;
-(void)editScriptViewDidPressAddFiltersForMetro;

@end

@interface EditScriptView : NSView <NSTextViewDelegate>

@property (nullable, weak) id<EditScriptViewDelegate> delegate;

@property (unsafe_unretained) IBOutlet NSTextView *customizeScriptTextView;
@property (strong) IBOutlet NSView *containerView;
@property (weak) IBOutlet NSButton *runScriptButton;

+ (NSString*)loadCustomizedScript;

// IBActions - Customize Script Pane
- (IBAction)customizeDefaultPressed:(nullable id)sender;
- (IBAction)editPaneRunScriptPressed:(nullable id)sender;
- (IBAction)editPaneClosePressed:(nullable id)sender;
- (IBAction)addFiltersForMetroPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
