//
//  NSDataExtensions.m
//  RainbowLogger
//

#import <Foundation/Foundation.h>
#import "NSDataExtensions.h"

// -----------------------------------------------------------------------------
// NSData additions.
// -----------------------------------------------------------------------------

/**
 Extension of the NSData class.
 Data can be found forwards or backwards. Further the extension supplies a function
 to convert the contents to string for debugging purposes.
 */
@implementation NSData (Additions)

/**
 Returns a range of data.
 @param dataToFind Data object specifying the delimiter and encoding.
 @returns A range.
 */
- (NSRange)rangeOfData:(NSData*)dataToFind {
    
    const void* bytes = [self bytes];
    NSUInteger length = [self length];
    const void* searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        // The current character matches.
        if (((char*)bytes)[index] == ((char*)searchBytes)[searchIndex]) {
            // Store found location if not done earlier.
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            // Increment search character index to check for match.
            searchIndex++;
            // All search character match.
            // Break search routine and return found position.
            if (searchIndex >= searchLength) {
                return foundRange;
            }
        }
        // Match does not continue.
        // Return to the first search character.
        // Discard former found location.
        else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding {
    return [[NSString alloc] initWithData:self encoding:encoding];
}

@end
