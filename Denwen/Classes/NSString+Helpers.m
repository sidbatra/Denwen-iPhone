//
//  NSString+Helpers.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "NSString+Helpers.h"

static NSString* const kEncryptionPhrase = @"9u124hgd35677";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation NSString (Helpers)

- (NSString*)stringByEncodingHTMLCharacters {
	
	NSMutableString *escaped = [NSMutableString stringWithString:
								[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSInteger length = [escaped length];
	
	[escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	[escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, length)];
	
	return [NSString stringWithString:escaped];
}

//----------------------------------------------------------------------------------------------------
-(NSString*) encrypt {
	NSData *key			= [NSData dataWithBytes:[[kEncryptionPhrase sha256] bytes] 
										 length:kCCKeySizeAES128];
	NSData *cipher		= [[self dataUsingEncoding:NSUTF8StringEncoding] aesEncryptedDataWithKey:key];
	
	return [NSString stringWithString:[cipher base64Encoding]];
}

//----------------------------------------------------------------------------------------------------
- (NSData*)sha256 {
    unsigned char *buffer;
	
    if ( ! ( buffer = (unsigned char *) malloc( CC_SHA256_DIGEST_LENGTH ) ) ) return nil;
	
    CC_SHA256( [self UTF8String], [self lengthOfBytesUsingEncoding: NSUTF8StringEncoding], buffer );
	
    return [NSData dataWithBytesNoCopy: buffer length: CC_SHA256_DIGEST_LENGTH];
}

@end
