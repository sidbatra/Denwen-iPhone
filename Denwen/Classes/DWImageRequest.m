//
//  DWImageRequest.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWImageRequest.h"

#import "ASIDownloadCache.h"
#import "DWConstants.h"

static NSInteger const kCacheTimeout = 15 * 24 * 60 * 60;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWImageRequest


//----------------------------------------------------------------------------------------------------
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData {
	/**
	 * Package the received image along with its type and owner info
	 */
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:self.resourceID]	,kKeyResourceID,
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
		successNotification:(NSString*)theSuccessNotification
		  errorNotification:(NSString*)theErrorNotification {
	
	DWImageRequest *imageRequest = [super requestWithRequestURL:requestURL
											successNotification:theSuccessNotification
											  errorNotification:theErrorNotification
													 resourceID:theResourceID];
	
	[imageRequest setDownloadCache:[ASIDownloadCache sharedCache]];
	[imageRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	[imageRequest setSecondsToCache:kCacheTimeout];
	
	return imageRequest;
}

@end
