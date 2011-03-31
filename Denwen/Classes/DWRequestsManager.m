//
//  DWRequestsManager.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#import "DWRequestsManager.h"

static NSString* const kDenwenProtocol			= @"http://";
static NSString* const kDenwenRequestURI		= @"%@%@%@&email=%@&password=%@&ff=mobile";

static NSString* const kPopularPlacesURI		= @"/popular/places.json?page=%d";
static NSString* const kNearbyPlacesURI			= @"/nearby/places.json?lat=%f&lon=%f";
static NSString* const kUserPlacesURI			= @"/users/%d/places.json?ignore=1";
static NSString* const kSearchPlacesURI			= @"/search/places.json?q=%@";
static NSString* const kPlaceURI				= @"/p/%@.json?page=%d";
static NSString* const kPlaceUpdatePhotoURI		= @"/places/%d.json?photo_filename=%@";
static NSString* const kNewPlaceURI				= @"/places.json?place[name]=%@&place[lat]=%f&place[lon]=%f&place[photo_filename]=%@";
static NSString* const kVisitsURI				= @"/visits.json?lat=%f&lon=%f";
static NSString* const kFollowingsURI			= @"/followings.json?place_id=%d";
static NSString* const kFollowingsDestroyURI	= @"/followings/%d.json?ignore=1";
static NSString* const kUserURI					= @"/users/%d.json?page=%d";
static NSString* const kUserUpdatePhotoURI		= @"/users/%d.json?photo_filename=%@";
static NSString* const kUserUpdateTwitterURI	= @"/users/%d.json?twitter_data=%@";
static NSString* const kUserUpdateFacebookURI	= @"/users/%d.json?facebook_data=%@";
static NSString* const kUserUpdateDeviceURI		= @"/users/%d.json?iphone_device_id=%@";
static NSString* const kUserUpdateSubtrahendURI	= @"/users/%d.json?unread_subtrahend=%d";
static NSString* const kFollowedItemsURI		= @"/followed/items.json?page=%d";
static NSString* const kNewItemURI				= @"/items.json?item[data]=%@&item[place_id]=%d&attachment[filename]=%@";
static NSString* const kNewUserURI				= @"%@%@/users.json?user[full_name]=%@&user[email]=%@&user[password]=%@&user[photo_filename]=%@&ff=mobile";
static NSString* const kNewSessionURI			= @"%@%@/session.json?email=%@&password=%@&ff=mobile";
static NSString* const kNewShareURI				= @"/shares.json?data=%@&sent_to=%d&place_id=%d";

static NSString* const kGet						= @"GET";
static NSString* const kPost					= @"POST";
static NSString* const kPut						= @"PUT";
static NSString* const kDelete					= @"DELETE";

static NSInteger const kDefaultResourceID		= -1;



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
	return	[NSString stringWithFormat:kDenwenRequestURI,
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
- (void)getPopularPlaces:(NSInteger)page {
	
	NSString *localRequestURL = [NSString stringWithFormat:kPopularPlacesURI,
									page];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNPopularPlacesLoaded 
			errorNotification:kNPopularPlacesError 
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)getNearbyPlaces {
	
	NSString *localRequestURL = [NSString stringWithFormat:kNearbyPlacesURI,
									 [DWSession sharedDWSession].location.coordinate.latitude,
									 [DWSession sharedDWSession].location.coordinate.longitude];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNNearbyPlacesLoaded 
			errorNotification:kNNearbyPlacesError 
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)getUserPlaces:(NSInteger)userID {
	
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
- (void)getSearchPlaces:(NSString*)query {
	NSString *localRequestURL = [NSString stringWithFormat:kSearchPlacesURI,
								 [query stringByEncodingHTMLCharacters]
								 ];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNSearchPlacesLoaded 
			errorNotification:kNSearchPlacesError 
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)getPlaceWithHashedID:(NSString*)hashedID 
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
- (void)createVisit {
	
	NSString *localRequestURL = [NSString stringWithFormat:kVisitsURI,
									[DWSession sharedDWSession].location.coordinate.latitude,
									[DWSession sharedDWSession].location.coordinate.longitude];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPost];
}

//----------------------------------------------------------------------------------------------------
- (void)createPlaceNamed:(NSString*)name
			  atLocation:(CLLocationCoordinate2D)location
			   withPhoto:(NSString*)photoFilename {
	
	NSString *localRequestURL = [NSString stringWithFormat:kNewPlaceURI,
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
- (void)createFollowing:(NSInteger)placeID {
	
	NSString *localRequestURL = [NSString stringWithFormat:kFollowingsURI,
									placeID];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNNewFollowingCreated
			errorNotification:kNNewFollowingError
				requestMethod:kPost
				   resourceID:placeID];
}

//----------------------------------------------------------------------------------------------------
- (void)destroyFollowing:(NSInteger)followingID 
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
- (void)getUserWithID:(NSInteger)userID
			   atPage:(NSInteger)page {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserURI,
									userID,
									page];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNUserLoaded
			errorNotification:kNUserError
				requestMethod:kGet
				   resourceID:userID];
}

//----------------------------------------------------------------------------------------------------
- (void)updatePhotoForUserWithID:(NSInteger)userID
			   withPhotoFilename:(NSString*)photoFilename {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserUpdatePhotoURI,
									 userID,
									 photoFilename];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNUserUpdated
			errorNotification:kNUserUpdateError
				requestMethod:kPut
				   resourceID:userID];
}

//----------------------------------------------------------------------------------------------------
- (void)updateTwitterDataForCurrentUser:(NSString*)twitterData {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserUpdateTwitterURI,
									[DWSession sharedDWSession].currentUser.databaseID,
									[twitterData stringByEncodingHTMLCharacters]];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPut];
}

//----------------------------------------------------------------------------------------------------
- (void)updateFacebookTokenForCurrentUser:(NSString*)facebookToken {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserUpdateFacebookURI,
								 [DWSession sharedDWSession].currentUser.databaseID,
								 [facebookToken stringByEncodingHTMLCharacters]];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPut];
}

//----------------------------------------------------------------------------------------------------
- (void)updateDeviceIDForCurrentUser:(NSString*)deviceID {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserUpdateDeviceURI,
									[DWSession sharedDWSession].currentUser.databaseID,
									[deviceID stringByEncodingHTMLCharacters]];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPut];
}

//----------------------------------------------------------------------------------------------------
- (void)updateUnreadCountForCurrentUserBy:(NSInteger)subtrahend {
	
	NSString *localRequestURL = [NSString stringWithFormat:kUserUpdateSubtrahendURI,
								 [DWSession sharedDWSession].currentUser.databaseID,
								 subtrahend];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPut];
}

//----------------------------------------------------------------------------------------------------
- (void)getFollowedItemsAtPage:(NSInteger)page {
	
	NSString *localRequestURL = [NSString stringWithFormat:kFollowedItemsURI,
										page];
	
	[self createDenwenRequest:localRequestURL 
		  successNotification:kNFollowedItemsLoaded
			errorNotification:kNFollowedItemsError
				requestMethod:kGet];
}

//----------------------------------------------------------------------------------------------------
- (void)createItemWithData:(NSString*)data 
	withAttachmentFilename:(NSString*)filename
			 atPlaceWithID:(NSInteger)placeID {
	
	NSString *localRequestURL = [NSString stringWithFormat:kNewItemURI,
										[data stringByEncodingHTMLCharacters],
										placeID,
										filename];
	
	[self createDenwenRequest:localRequestURL
		  successNotification:kNNewItemCreated
			errorNotification:kNNewItemError
				requestMethod:kPost];
}

//----------------------------------------------------------------------------------------------------
- (void)createUserWithName:(NSString*)name
				 withEmail:(NSString*)email
			  withPassword:(NSString*)password
		 withPhotoFilename:(NSString*)photoFilename {
	
	NSString *requestURL  = [NSString stringWithFormat:kNewUserURI,
								 kDenwenProtocol,
								 kDenwenServer,
								 [name stringByEncodingHTMLCharacters],
								 [email stringByEncodingHTMLCharacters],
								 password,
								 photoFilename];
	
	DWDenwenRequest *request = [DWDenwenRequest requestWithRequestURL:requestURL
												  successNotification:kNNewUserCreated
													errorNotification:kNNewUserError];
	[request setDelegate:self];
	[request setRequestMethod:kPost];
	[request startAsynchronous];
}

//----------------------------------------------------------------------------------------------------
- (void)createSessionWithEmail:(NSString*)email
				  withPassword:(NSString*)password {
	
	NSString *requestURL = [NSString stringWithFormat:kNewSessionURI,
								kDenwenProtocol,
								kDenwenServer,
								[email stringByEncodingHTMLCharacters],
								password];
	
	DWDenwenRequest *request = [DWDenwenRequest requestWithRequestURL:requestURL
												  successNotification:kNNewSessionCreated
													errorNotification:kNNewSessionError];
	[request setDelegate:self];
	[request setRequestMethod:kPost];
	[request startAsynchronous];
}

//----------------------------------------------------------------------------------------------------
- (void)createShareForPlaceWithID:(NSInteger)placeID
						 withData:(NSString*)data
						   sentTo:(NSInteger)sentTo { 
	
	NSString *localRequestURL = [NSString stringWithFormat:kNewShareURI,
									[data stringByEncodingHTMLCharacters],
									sentTo,
									placeID];
		
	[self createDenwenRequest:localRequestURL
		  successNotification:nil
			errorNotification:nil
				requestMethod:kPost];
}

//----------------------------------------------------------------------------------------------------
- (void)getImageAt:(NSString*)url 
	withResourceID:(NSInteger)resourceID
successNotification:(NSString*)theSuccessNotification
 errorNotification:(NSString*)theErrorNotification {
	
	DWImageRequest *request = [DWImageRequest requestWithRequestURL:url 
														 resourceID:resourceID
												successNotification:theSuccessNotification
												  errorNotification:theErrorNotification];
	[request setDelegate:self];
	[request setRequestMethod:kGet];
	[request startAsynchronous];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)createImageWithData:(UIImage*)image
						toFolder:(NSString*)folder {
	
	DWS3Request *request = [DWS3Request requestNewImage:image
											   toFolder:folder];
	[request setDelegate:self];
	[request startAsynchronous];
	
	return request.resourceID;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)createVideoUsingURL:(NSURL*)theURL
				   atOrientation:(NSString*)orientation 
						toFolder:(NSString*)folder {
	
	DWS3Request *request = [DWS3Request requestNewVideo:theURL 
										  atOrientation:orientation
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
