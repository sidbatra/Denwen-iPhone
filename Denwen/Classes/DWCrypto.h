//
//  DWCrypto.h
//  Denwen
//
//  Created by Siddharth Batra on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>


@interface DWCrypto : NSObject {

}

+ (NSString*)encryptString:(NSString*)plaintext;

@end


@interface NSData(Crypto)
- (NSData *) aesEncryptedDataWithKey:(NSData *) key;
- (NSString *) base64Encoding;
@end


@interface NSString(Crypto)
- (NSData *) sha256;
@end

