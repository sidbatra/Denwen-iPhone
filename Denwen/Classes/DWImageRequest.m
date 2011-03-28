//
//  DWImageRequest.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWImageRequest.h"

static NSInteger const kCacheTimeout = 15 * 24 * 60 * 60;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWImageRequest

@synthesize imageType	= _imageType;


//----------------------------------------------------------------------------------------------------
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData {
	/**
	 * Package the received image along with its type and owner info
	 */
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:self.resourceID]	,kKeyResourceID,
							  [NSNumber numberWithInt:self.imageType]	,kKeyImageType,
							  [UIImage imageWithData:responseData]		,kKeyImage,
							  nil];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:self.successNotification 
														object:nil
													  userInfo:info];
	
	
}

//----------------------------------------------------------------------------------------------------
- (void)processError:(NSError*)theError {
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:self.resourceID]		,kKeyResourceID,
						  [NSNumber numberWithInt:self.imageType]		,kKeyImageType,
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
+ (id)requestWithRequestURL:(NSString*)requestURL 
				 resourceID:(NSInteger)theResourceID
				  imageType:(NSInteger)theImageType {
	
	DWImageRequest *imageRequest	= [super requestWithRequestURL:requestURL
											   successNotification:kNImageLoaded
												 errorNotification:kNImageError
														resourceID:theResourceID];
	imageRequest.imageType			= theImageType;
	
	[imageRequest setDownloadCache:[ASIDownloadCache sharedCache]];
	[imageRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	[imageRequest setSecondsToCache:kCacheTimeout];
	
	return imageRequest;
}

@end
