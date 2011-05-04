//
//  NSData+Crypto.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

/**
 * Extend NSData to add support for Cryptography
 */
@interface NSData(Crypto)

- (NSData*)aesEncryptedDataWithKey:(NSData*)key;
- (NSString*)base64Encoding;

@end

