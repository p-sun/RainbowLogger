//
//  NSView+NSViewNib.h
//  iOSLogConsole
//
//  Created by Paige Sun on 1/3/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import "NSViewExtensions.h"

//@implementation NSViewExtensions
@implementation NSView (Additions)

+ (id)loadWithNibNamed:(NSString *)nibNamed class:(Class)loadClass owner:(id)owner {
    NSNib * nib = [[NSNib alloc] initWithNibNamed:nibNamed bundle:nil];
    
    NSArray * objects;
    if (![nib instantiateWithOwner:owner topLevelObjects:&objects]) {
        NSLog(@"(PAIGE) Couldn't load nib named %@", nibNamed);
        return nil;
    }
    
    for (id object in objects) {
        if ([object isKindOfClass:loadClass]) {
            return object;
        }
    }
    return nil;
}

- (void)constrainToSuperview {
  NSView *superview = [self superview];
  [self setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [[[self topAnchor] constraintEqualToAnchor:[superview topAnchor] constant:0] setActive:YES];
  [[[self leadingAnchor] constraintEqualToAnchor:[superview leadingAnchor] constant:0] setActive:YES];
  [[[self trailingAnchor] constraintEqualToAnchor:[superview trailingAnchor] constant:0] setActive:YES];
  [[[self bottomAnchor] constraintEqualToAnchor:[superview bottomAnchor] constant:0] setActive:YES];
}

@end
