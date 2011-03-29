//
//  DWRequestsManager.h
//  Copyright 2011 Denwen. All rights reserved.
//	

#import <Foundation/Foundation.h>

// Requests
#import "DWDenwenRequest.h"
#import "DWImageRequest.h"
#import "DWS3Request.h"

#import "NSString+Helpers.h"
#import "SynthesizeSingleton.h"
#import "DWSession.h"
#import "Constants.h"


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
- (void)requestPopularPlaces:(NSInteger)page;

/**
 * Nearby places based on the user's current location
 */
- (void)requestNearbyPlaces;

/**
 * Places followed by a specific user
 */
- (void)requestUserPlaces:(NSInteger)userID;

/**
 * Search query on the places table
 */
- (void)requestSearchPlaces:(NSString*)query;

/**
 * Place view with page representing items pagination
 */
- (void)requestPlaceWithHashedID:(NSString*)hashedID 
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
- (void)requestNewVisit;

/**
 * Create a new place
 */
- (void)requestNewPlaceNamed:(NSString*)name
				  atLocation:(CLLocationCoordinate2D)location
				   withPhoto:(NSString*)photoFilename;

/**
 * Create a new following for a place
 */
- (void)requestNewFollowing:(NSInteger)placeID;

/**
 * Destroy an existing following for a place
 */
- (void)requestDestroyFollowing:(NSInteger)followingID 
				  ofPlaceWithID:(NSInteger)placeID;


/**
 * Download the image from the given URL
 */
- (void)requestImageAt:(NSString*)url 
				ofType:(NSInteger)imageType 
		withResourceID:(NSInteger)resourceID;

/**
 * Upload an image to a S3 folder. Method returns
 * the resource ID to uniquely identify the image upload
 */
- (NSInteger)requestNewImageWithData:(UIImage*)image
							toFolder:(NSString*)folder;

@end