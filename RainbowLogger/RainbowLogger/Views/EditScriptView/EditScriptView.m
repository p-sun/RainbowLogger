//
//  EditScriptView.m
//  RainbowLogger
//
//  Created by Paige Sun on 1/3/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import "EditScriptView.h"
#import "NSViewExtensions.h"

@implementation EditScriptView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialize _containerView & call awakeFromNib
    [NSView loadWithNibNamed:@"EditScriptView" class:EditScriptView.class owner:self];
    
    _containerView.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);
    [self addSubview:_containerView];
    [_containerView constrainToSuperview];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  
  // with this set to YES, quotes typed into the NSTextView are different
  // from escaped quotes set in defaultScript      i.e.  \"
  _customizeScriptTextView.automaticQuoteSubstitutionEnabled = NO;
  
  _customizeScriptTextView.delegate = self;
  
  [self setupDefaults];
}

#pragma mark - IBActions for Edit Script Pane

- (IBAction)customizeDefaultPressed:(nullable id)sender {
  NSString *defaultScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --predicate '(NOT (subsystem contains \"com.apple\"))'";
  [_customizeScriptTextView setString:defaultScript];
  [self saveCustomizedScript:defaultScript];
}

- (IBAction)scriptForValidPressed:(id)sender {
  NSString *defaultScript = @"cd ~/Snapchat/Dev/mobile/client/src/composer_modules; ./scripts/show_logs.py";
  [_customizeScriptTextView setString:defaultScript];
  [self saveCustomizedScript:defaultScript];
}

- (IBAction)scriptForPhantomPressed:(id)sender {
  NSString *defaultScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --process=Snapchat --predicate '(NOT (subsystem contains \"com.apple\")) AND (NOT (eventType == \"activityCreateEvent\"))'";
  [_customizeScriptTextView setString:defaultScript];
  [self saveCustomizedScript:defaultScript];
}

- (IBAction)scriptForFbiosPressed:(id)sender {
  NSString *defaultScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --process=Facebook --predicate '(NOT (subsystem contains \"com.apple\")) AND (eventMessage contains \"****\" OR eventMessage contains \"RCTStaticInjectionAutoInit()_block_invoke_2\" OR eventMessage contains \"FBReactModule\")'";
  [_customizeScriptTextView setString:defaultScript];
  [self saveCustomizedScript:defaultScript];
}

- (IBAction)editPaneRunScriptPressed:(nullable id)sender {
  [self saveCustomizedScript:_customizeScriptTextView.string];
  [_delegate editScriptViewDidPressRunScript];
}
- (IBAction)addFiltersForMetroPressed:(id)sender {
  [_delegate editScriptViewDidPressAddFiltersForMetro];
}

- (IBAction)addFiltersForValdiPressed:(id)sender {
  [_delegate editScriptViewDidPressAddFiltersForValdi];
}

- (IBAction)editPaneClosePressed:(nullable id)sender {
  [_delegate editScriptViewDidPressClose];
}

- (void)setupDefaults {
  //   ----------------------------------------------------------
  //   Override the saved script for the "Attach Logger" button
  //   ----------------------------------------------------------
  
  //   --- Script for getting device logs ---
  //   NSString *newScript = @"idevicesyslog -p Facebook -m \"****\"";
  
  //   --- My preferred log for getting logs from simulator ---
  //   Really close to Flipper's logs. Still shows some Network and Security logs though.
  //   Test command in terminal by removing the \ escape before the quotes.
  //   NSString *newScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --process=Facebook --predicate '(NOT (subsystem contains \"com.apple\")) AND eventMessage contains \"****\"\'";
  
  //   --- For testing new start ---
  //    NSString *newScript = nil;
  
  // --- Save script ---
  //    [self saveCustomizedScript:newScript];
  //   ----------------------------------------------------------
  
  NSString *script = [EditScriptView loadCustomizedScript];
  if (script == nil) {
    [self customizeDefaultPressed:nil];
  } else if (![script isEqualToString:_customizeScriptTextView.string]) {
    [_customizeScriptTextView setString:script];
  }
}
  
#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification {
  NSTextView *textView = notification.object;
  if (textView == _customizeScriptTextView) {
    NSString *oldScript = [EditScriptView loadCustomizedScript];
    NSString *newScript = _customizeScriptTextView.string;
    BOOL didTextChange = ![oldScript isEqualToString:newScript];
    if (didTextChange) {
      [self saveCustomizedScript:newScript];
    }
  }
}

#pragma mark - Save and Load Script

- (void)saveCustomizedScript:(NSString*)newScript {
  [[NSUserDefaults standardUserDefaults] setValue:newScript forKey:@"UserDefaultsKeyCustomizedScript"];
}

+ (NSString*)loadCustomizedScript {
  return [[NSUserDefaults standardUserDefaults] valueForKey:@"UserDefaultsKeyCustomizedScript"];
}

@end
