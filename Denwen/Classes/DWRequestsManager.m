//
//  DWRequestsManager.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#import "DWRequestsManager.h"

static NSString* const kDenwenProtocol			= @"http://";

static NSString* const kPopularPlacesURI		= @"/popular/places.json?page=%d";
static NSString* const kNearbyPlacesURI			= @"/nearby/places.json";
static NSString* const kUserPlacesURI			= @"/users/%d/places.json?ignore=1";
static NSString* const kSearchPlacesURI			= @"/search/places.json";
static NSString* const kPlaceURI				= @"/p/%@.json?page=%d";
static NSString* const kPlaceUpdatePhotoURI		= @"/places/%d.json?photo_filename=%@";
static NSString* const kNewPlaceURI				= @"/places.json";
static NSString* const kVisitsURI				= @"/visits.json";
static NSString* const kFollowingsURI			= @"/followings.json";
static NSString* const kFollowingsDestroyURI	= @"/followings/%d.json?ignore=1";


static NSString* const kGet						= @"GET";
static NSString* const kPost					= @"POST";
static NSString* const kPut						= @"PUT";
static NSString* const kDelete					= @"DELETE";

static NSInteger const kDefaultResourceID	= -1;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWRequestsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DWRequestsManager);


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private

//----------------------------------------------------------------------------------------------------
- (NSString*)createDenwenRequestURL:(NSString*)localRequestURL {
	
	/**
	 * Based on the server configuration convert the given local request url
	 * to an absolute one
	 */
	return	[NSString stringWithFormat:@"%@%@%@&email=%@&password=%@&ff=mobile",
				kDenwenProtocol,
				kDenwenServer,
				localRequestURL,
				[[DWSession sharedDWSession].currentUser.email stringByEncodingHTMLCharacters],
				[DWSession sharedDWSession].currentUser.encryptedPassword];
}

//----------------------------------------------------------------------------------------------------
- (void)createDenwenRequest:(NSString*)localRequestURL 
		successNotification:(NSString*)successNotification
		  errorNotification:(NSString*)errorNotification
			  requestMethod:(NSString*)requestMethod
				 resourceID:(NSInteger)resourceID {
	
	/**
	 * Create and launch a Denwen request
	 */
	NSString *requestURL = [self createDenwenRequestURL:localRequestURL];
	
	DWDenwenRequest *request = [DWDenwenRequest requestWithRequestURL:requestURL
												  successNotification:successNotification
													errorNotification:errorNotification
														   resourceID:resourceID];
	[request setDelegate:self];
	[request setRequestMethod:requestMethod];
	[request startAsynchronous];	
}

//----------------------------------------------------------------------------------------------------
- (void)createDenwenRequest:(NSString*)localRequestURL 
		successNotification:(NSString*)successNotification
		  errorNotification:(NSString*)errorNotification
			  requestMethod:(NSString*)requestMethod {
	
	/**
	 * Overloaded version of createDenwenRequest with default resource ID
	 */
	[self createDenwenRequest:localRequestURL 
		  successNotification:successNotification 
			errorNotification:errorNotification 
				requestMethod:requestMethod
				   resourceID:kDefaultResourceID];
}
			

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Requests

//----------------------------------------------------------------------------------------------------
- (void)requestPopularPlaces:(NSInteger)page {
	
	NSString *localRequestURL = [NSString stringWithFormat:kPopularPlacesURI,
									page];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNPopularPlacesLoaded 
			errorNotification:kNPopularPlacesError 
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)requestNearbyPlaces {
	
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?lat=%f&lon=%f",
									 kNearbyPlacesURI,
									 [DWSession sharedDWSession].location.coordinate.latitude,
									 [DWSession sharedDWSession].location.coordinate.longitude];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNNearbyPlacesLoaded 
			errorNotification:kNNearbyPlacesError 
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)requestUserPlaces:(NSInteger)userID {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserPlacesURI,
									userID
								];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNUserPlacesLoaded 
			errorNotification:kNUserPlacesError 
				requestMethod:kGet
				   resourceID:userID];
}

//----------------------------------------------------------------------------------------------------
- (void)requestSearchPlaces:(NSString*)query {
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?q=%@",
								 kSearchPlacesURI,
								 [query stringByEncodingHTMLCharacters]
								 ];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNSearchPlacesLoaded 
			errorNotification:kNSearchPlacesError 
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)requestPlaceWithHashedID:(NSString*)hashedID 
				  withDatabaseID:(NSInteger)placeID
						  atPage:(NSInteger)page {
	
	NSString *localRequestURL = [NSString stringWithFormat:kPlaceURI,
									 hashedID,
									 page];
		
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNPlaceLoaded 
			errorNotification:kNPlaceError
				requestMethod:kGet
				   resourceID:placeID];
}

//----------------------------------------------------------------------------------------------------
- (void)updatePhotoForPlaceWithID:(NSInteger)placeID
				  toPhotoFilename:(NSString*)photoFilename {
	
	NSString *localRequestURL = [NSString stringWithFormat:kPlaceUpdatePhotoURI,
									 placeID,
									 photoFilename];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNPlaceUpdated
			errorNotification:kNPlaceUpdateError
				requestMethod:kPut
				   resourceID:placeID];
}

//----------------------------------------------------------------------------------------------------
- (void)requestNewVisit {
	
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?lat=%f&lon=%f",
									kVisitsURI,
									[DWSession sharedDWSession].location.coordinate.latitude,
									[DWSession sharedDWSession].location.coordinate.longitude];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPost];
}

//----------------------------------------------------------------------------------------------------
- (void)requestNewPlaceNamed:(NSString*)name
					   atLocation:(CLLocationCoordinate2D)location
						withPhoto:(NSString*)photoFilename {
	
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?place[name]=%@&place[lat]=%f&place[lon]=%f&place[photo_filename]=%@",
									kNewPlaceURI,
									[name stringByEncodingHTMLCharacters],
									location.latitude,
									location.longitude,
									photoFilename];	
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNNewPlaceCreated
			errorNotification:kNNewPlaceError
				requestMethod:kPost];
}

//----------------------------------------------------------------------------------------------------
- (void)requestNewFollowing:(NSInteger)placeID {
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?place_id=%d",
									kFollowingsURI,
									placeID];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNNewFollowingCreated
			errorNotification:kNNewFollowingError
				requestMethod:kPost
				   resourceID:placeID];
}

//----------------------------------------------------------------------------------------------------
- (void)requestDestroyFollowing:(NSInteger)followingID 
				  ofPlaceWithID:(NSInteger)placeID {
	NSString *localRequestURL = [NSString stringWithFormat:kFollowingsDestroyURI,
									followingID];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNFollowingDestroyed
			errorNotification:kNFollowingDestroyError
				requestMethod:kDelete
				   resourceID:placeID];
}



//----------------------------------------------------------------------------------------------------
- (void)requestImageAt:(NSString*)url 
				ofType:(NSInteger)imageType 
		withResourceID:(NSInteger)resourceID {
	
	DWImageRequest *request = [DWImageRequest requestWithRequestURL:url 
														 resourceID:resourceID
														  imageType:imageType];
	[request setDelegate:self];
	[request setRequestMethod:kGet];
	[request startAsynchronous];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)requestNewImageWithData:(UIImage*)image
					   toFolder:(NSString*)folder {
	
	DWS3Request *request = [DWS3Request requestNewImage:image
											   toFolder:folder];
	[request setDelegate:self];
	[request startAsynchronous];
	
	return request.resourceID;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ASIHTTPRequestDelegate

//----------------------------------------------------------------------------------------------------
- (void)requestFinished:(DWRequest *)request {
	[request processResponse:[request responseString] andResponseData:[request responseData]];
}

//----------------------------------------------------------------------------------------------------
- (void)requestFailed:(DWRequest *)request {
	[request processError:[request error]];
}



@end
