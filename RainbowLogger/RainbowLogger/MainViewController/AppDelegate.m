//
//  AppDelegate.m
//  RainbowLogger
//
//  Created by Paige Sun on 2020-05-24.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [NSApp setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameDarkAqua]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
