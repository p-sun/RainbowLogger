//
//  NSDataExtensions.h
//  iOSLogConsole
//
//  Created by Paige Sun on 2020-05-25.
//  Copyright © 2020 Paige Sun. All rights reserved.
//

#ifndef NSDataExtensions_h
#define NSDataExtensions_h

// -----------------------------------------------------------------------------
// NSData additions.
// -----------------------------------------------------------------------------

@interface NSData (Additions)

- (NSRange)rangeOfData:(NSData*)dataToFind;
- (NSRange)rangeOfDataBackwardsSearch:(NSData*)dataToFind;
- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding;

@end


// -----------------------------------------------------------------------------
// NSMutableData additions.
// -----------------------------------------------------------------------------

@interface NSMutableData (Additions)

- (void)prepend:(NSData*)data;

@end
#endif /* NSDataExtensions_h */
