//
//  EditScriptView.h
//  iOSLogConsole
//
//  Created by Paige Sun on 1/3/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EditScriptViewDidPressCloseButtonNotification = @"EditScriptViewDidPressCloseButtonNotification";

@protocol EditScriptViewDelegate <NSObject>

-(void)editScriptViewDidPressCloseButton;

@end

@interface EditScriptView : NSView <NSTextViewDelegate>

@property (nullable, weak) id<EditScriptViewDelegate> delegate;

@property (unsafe_unretained) IBOutlet NSTextView *customizeScriptTextView;
@property (strong) IBOutlet NSView *containerView;

// IBActions - Customize Script Pane
- (IBAction)customizeDefaultPressed:(id)sender;
- (IBAction)editPaneRunScriptPressed:(id)sender;
- (IBAction)editPaneClosePressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
