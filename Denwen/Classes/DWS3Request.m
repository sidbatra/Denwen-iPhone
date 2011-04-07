//
//  DWS3Request.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWS3Request.h"

#import "DWConstants.h"

static NSInteger const kRandomStringLength	= 20;
static NSInteger const kRandomStringBase	= 10;

static NSString* const kImageSuffix			= @"photo.jpg";
static NSString* const kImageContentType	= @"image/jpeg";
static float	 const kImageCompression	= 0.5;
static NSString* const kVideoContentType	= @"video/quicktime";
static NSString* const kVideoSuffixFormat	= @"video_o_%@.mov";

static NSString* const kS3KeyPolicy			= @"policy";
static NSString* const kS3KeySignature		= @"signature";
static NSString* const kS3KeyAcessID		= @"AWSAccessKeyId";
static NSString* const kS3KeyACL			= @"acl";
static NSString* const kS3KeyKey			= @"key";
static NSString* const kS3KeyFile			= @"file";
static NSString* const kS3SuccessResponse	= @"";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWS3Request

@synthesize filename	= _filename;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private

//----------------------------------------------------------------------------------------------------
+ (id)createRequestWithSuffix:(NSString*)suffix 
					 toFolder:(NSString*)folder {
	
	DWS3Request *s3Request = [super requestWithRequestURL:kS3Server
									  successNotification:kNS3UploadDone
										errorNotification:kNS3UploadError
											   resourceID:[[NSDate date] timeIntervalSince1970]];
	
	NSMutableString *randomString = [NSMutableString stringWithString:@""];
	
	for(int i=0;i<kRandomStringLength;i++)
		[randomString appendFormat:@"%d",arc4random() % kRandomStringBase];
	
	s3Request.filename = [NSString stringWithFormat:@"%d_%@_%@",s3Request.resourceID,randomString,suffix];
	
	
	[s3Request setShouldStreamPostDataFromDisk:YES];
	
	
	NSString *key = [NSString stringWithFormat:@"%@/${filename}",folder];
	
	[s3Request setPostValue:kS3Policy		forKey:kS3KeyPolicy];
	[s3Request setPostValue:kS3Signature	forKey:kS3KeySignature];
	[s3Request setPostValue:kS3AccessID		forKey:kS3KeyAcessID];
	[s3Request setPostValue:kS3ACL			forKey:kS3KeyACL];
	[s3Request setPostValue:key				forKey:kS3KeyKey];
	
	return s3Request;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.filename = nil;
	
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData {	
	/**
	 * Test response from S3 server and launch success or error request accordingly
	 */
	if([responseString isEqualToString:kS3SuccessResponse]) {
		
		NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:self.resourceID]	,kKeyResourceID,
							   self.filename							,kKeyFilename,
							   nil];

		[[NSNotificationCenter defaultCenter] postNotificationName:self.successNotification 
															object:nil
														  userInfo:info];
	}
	else {
		NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:self.resourceID]	,kKeyResourceID,
							   @""										,kKeyErrorMessage,	
							   nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:self.errorNotification
															object:nil
														  userInfo:info];
	}

	
	
}

//----------------------------------------------------------------------------------------------------
- (void)processError:(NSError*)theError {
		
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:self.resourceID]		,kKeyResourceID,
						  theError										,kKeyError,
						  nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:self.errorNotification
														object:nil
													  userInfo:info];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Static

//----------------------------------------------------------------------------------------------------
+ (id)requestNewImage:(UIImage*)image
			 toFolder:(NSString*)folder {
	
	DWS3Request *s3Request = [self createRequestWithSuffix:kImageSuffix 
												  toFolder:folder];
	
	[s3Request setData:(NSData*)UIImageJPEGRepresentation(image,kImageCompression) 
		  withFileName:s3Request.filename
		andContentType:kImageContentType 
				forKey:kS3KeyFile];
	
	return s3Request;
}

//----------------------------------------------------------------------------------------------------
+ (id)requestNewVideo:(NSURL*)theURL
		atOrientation:(NSString*)orientation
			 toFolder:(NSString*)folder {

	DWS3Request *s3Request = [self createRequestWithSuffix:[NSString stringWithFormat:kVideoSuffixFormat,orientation]
												  toFolder:folder];

	[s3Request setFile:[theURL relativePath]
		  withFileName:s3Request.filename 
		andContentType:kVideoContentType 
				forKey:kS3KeyFile];
	
	return s3Request;
}


@end
