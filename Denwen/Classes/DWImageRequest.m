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
@synthesize ownerID		= _ownerID;


//----------------------------------------------------------------------------------------------------
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData {
	/**
	 * Package the received image along with its type and owner info
	 */
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:self.ownerID]		,kKeyOwnerID,
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
						  [NSNumber numberWithInt:self.ownerID]			,kKeyOwnerID,
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
					ownerID:(NSInteger)theOwnerID
				  imageType:(NSInteger)theImageType {
	
	DWImageRequest *imageRequest	= [super requestWithRequestURL:requestURL
											   successNotification:kNImageLoaded
												 errorNotification:kNImageError];
	imageRequest.imageType			= theImageType;
	imageRequest.ownerID			= theOwnerID;
	
	[imageRequest setDownloadCache:[ASIDownloadCache sharedCache]];
	[imageRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	[imageRequest setSecondsToCache:kCacheTimeout];
	
	return imageRequest;
}

@end
