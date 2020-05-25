//
//  FilterCell.m
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

- (void)awakeFromNib {
    for (FilterColor *filterColor in [FilterColor allColors]) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:filterColor.name action:nil keyEquivalent:@""];
        menuItem.image = [self swatchForColor:filterColor.color];
        [self.colorsPopup.menu addItem:menuItem];
    }
}

- (NSImage *)swatchForColor:(NSColor *)color {
    NSSize size = NSMakeSize(12, 12);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [color drawSwatchInRect:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    return image;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setFilter:(Filter *)filter {
    self.filterByText.stringValue = filter.text;
}

@end
