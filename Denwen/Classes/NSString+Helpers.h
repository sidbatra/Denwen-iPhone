//
//  NSString+Helpers.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSData+Crypto.h"

/**
 * Extension of the NSString class to add custom helpers
 */
@interface NSString (Helpers) 

/**
 * URI encode HTML characters in the given parameters
 */
- (NSString*)stringByEncodingHTMLCharacters;

/**
 * Encrytion with a pre-decided key and AES128
 */
- (NSString*)encrypt;

/**
 * Computes sha256 
 */
- (NSData*)sha256;

@end
