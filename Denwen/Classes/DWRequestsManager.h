//
//  DWRequestsManager.h
//  Copyright 2011 Denwen. All rights reserved.
//	

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 * DWRequestsManager enables absracted access to all network operations
 * via a simple interface
 */
@interface DWRequestsManager : NSObject {

}

/**
 * Shared sole instance of the class
 */
+ (DWRequestsManager *)sharedDWRequestsManager;

/**
 * Given page of the currently popular places
 */
- (void)getPopularPlaces:(NSInteger)page;

/**
 * Nearby places based on the user's current location
 */
- (void)getNearbyPlaces;

/**
 * Places followed by a specific user
 */
- (void)getUserPlaces:(NSInteger)userID;

/**
 * Search query on the places table
 */
- (void)getSearchPlaces:(NSString*)query;

/**
 * Place view with page representing items pagination
 */
- (void)getPlaceWithHashedID:(NSString*)hashedID 
			  withDatabaseID:(NSInteger)placeID
					  atPage:(NSInteger)page;

/**
 * Update the background photo for a place
 */
- (void)updatePhotoForPlaceWithID:(NSInteger)placeID
				  toPhotoFilename:(NSString*)photoFilename;

/**
 * Create a new visit
 */
- (void)createVisit;

/**
 * Create a new place
 */
- (void)createPlaceNamed:(NSString*)name
				 atLocation:(CLLocationCoordinate2D)location
				  withPhoto:(NSString*)photoFilename;

/**
 * Create a new following for a place
 */
- (void)createFollowing:(NSInteger)placeID;

/**
 * Destroy an existing following for a place
 */
- (void)destroyFollowing:(NSInteger)followingID 
		   ofPlaceWithID:(NSInteger)placeID;

/**
 * Create a new touch interaction
 */
- (void)createTouch:(NSInteger)itemID;

/**
 * Retrieve touches on items of the current user
 */
- (void)getTouchesForCurrentUser:(NSInteger)lastID;

/**
 * User profile with page representing items pagination
 */
- (void)getUserWithID:(NSInteger)userID
       fromLastItemID:(NSInteger)lastID;

/**
 * Update the display picture for a user
 */
- (NSInteger)updatePhotoForUserWithID:(NSInteger)userID
                    withPhotoFilename:(NSString*)photoFilename;

/**
 * Update twitter access token for the logged in user
 */
- (void)updateTwitterDataForCurrentUser:(NSString*)twitterData;

/**
 * Update facebook token for the logged in user
 */
- (void)updateFacebookTokenForCurrentUser:(NSString*)facebookToken;

/** 
 * Update iphone device id for the logged in user
 */
- (void)updateDeviceIDForCurrentUser:(NSString*)deviceID;

/** 
 * Update the unread count for the logged in user by reducing it
 * by the given amount
 */
- (void)updateUnreadCountForCurrentUserBy:(NSInteger)subtrahend;

/**
 * Recent items from the places followed by the current user
 * page provides pagination
 */
- (void)getFollowedItemsAtPage:(NSInteger)page;

/**
 * Create a new item
 */
- (NSInteger)createItemWithData:(NSString*)data 
		 withAttachmentFilename:(NSString*)filename
				  atPlaceWithID:(NSInteger)placeID;

/**
 * Create a new item along with a new place
 */
- (NSInteger)createItemWithData:(NSString*)data 
		 withAttachmentFilename:(NSString*)filename
				atPlaceWithName:(NSString*)name
					 atLocation:(CLLocationCoordinate2D)location;

/**
 * Create a new user
 */
- (void)createUserWithName:(NSString*)name
				 withEmail:(NSString*)email
			  withPassword:(NSString*)password
		 withPhotoFilename:(NSString*)photoFilename;

/**
 * Create a new session
 */
- (void)createSessionWithEmail:(NSString*)email
				  withPassword:(NSString*)password;

/** 
 * Createa a new share
 */
- (void)createShareForPlaceWithID:(NSInteger)placeID
						 withData:(NSString*)data
						   sentTo:(NSInteger)sentTo;

/**
 * Download the image from the given URL and fire the given
 * notifications
 */
- (void)getImageAt:(NSString*)url 
	withResourceID:(NSInteger)resourceID
successNotification:(NSString*)theSuccessNotification
 errorNotification:(NSString*)theErrorNotification;

/**
 * Upload an image to a S3 folder. Method returns
 * the resource ID to uniquely identify the image upload
 * uploadDelegate receive events about the upload progress
 */
- (NSInteger)createImageWithData:(UIImage*)image 
						toFolder:(NSString*)folder
			  withUploadDelegate:(id)uploadDelegate;

/**
 * Upload video located at the URL to the S3 folder. Method returns
 * the resource ID to unique identify the video upload
 * uploadDelegate receive events about the upload progress
 */
- (NSInteger)createVideoUsingURL:(NSURL*)theURL
				   atOrientation:(NSString*)orientation 
						toFolder:(NSString*)folder
			  withUploadDelegate:(id)uploadDelegate;

@end