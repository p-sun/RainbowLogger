//
//  EditScriptView.m
//  iOSLogConsole
//
//  Created by Paige Sun on 1/3/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import "EditScriptView.h"

@implementation EditScriptView

#pragma mark - Lifecycle

- (void)awakeFromNib {
  [super awakeFromNib];
  
  _customizeScriptTextView.delegate = self;
}

#pragma mark - IBActions for Edit Script Pane

- (IBAction)customizeDefaultPressed:(id)sender {
  NSString *defaultScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --predicate '(NOT (subsystem contains \"com.apple\"))'";
  _customizeScriptTextView.string = defaultScript;
  [self saveCustomizedScript:defaultScript];
}

- (IBAction)editPaneRunScriptPressed:(id)sender {
  [self saveCustomizedScript:_customizeScriptTextView.string];
//  [self runScriptPressed:nil]; // TODO
}

- (IBAction)editPaneClosePressed:(id)sender {
//  [[NSNotificationCenter defaultCenter] postNotificationName:EditScriptViewDidPressCloseButtonNotification object:nil];
  [self.delegate editScriptViewDidPressCloseButton];
}

- (void)setupCustomizeScriptTextView {
  //   ----------------------------------------------------------
  //   Override the saved script for the "Attach Logger" button
  //   ----------------------------------------------------------
  
  //   --- Script for getting device logs ---
//     NSString *newScript = @"idevicesyslog -p Facebook -m \"****\"";
  
  //   --- My preferred log for getting logs from simulator ---
  //   Really close to Flipper's logs. Still shows some Network and Security logs though.
  //   Test command in terminal by removing the \ escape before the quotes.
//     NSString *newScript = @"xcrun simctl spawn booted log stream --level=default --style=compact --process=Facebook --predicate '(NOT (subsystem contains \"com.apple\")) AND eventMessage contains \"****\"\'";

  //   --- For testing new start ---
//       NSString *newScript = nil;
  
  // --- Save script ---
//    [self saveCustomizedScript:newScript];
  //   ----------------------------------------------------------
  
  NSString *script = [self loadCustomizedScript];
  if (script == nil) {
    [self customizeDefaultPressed:nil];
  } else if (![script isEqualToString:_customizeScriptTextView.string]) {
    _customizeScriptTextView.string = script;
  }
}
  
#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification {
  NSTextView *textView = notification.object;
  if (textView == _customizeScriptTextView) {
    NSString *oldScript = [self loadCustomizedScript];
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

- (NSString*)loadCustomizedScript {
  return [[NSUserDefaults standardUserDefaults] valueForKey:@"UserDefaultsKeyCustomizedScript"];
}

@end
