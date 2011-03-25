//
//  NSString+Helpers.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Extension of the NSString class to add custom helpers
 */
@interface NSString (Helpers) 

/**
 * URI encode HTML characters in the given parameters
 */
- (NSString*)stringByEncodingHTMLCharacters;

@end
