//
//  DWRequestsManager.h
//  Copyright 2011 Denwen. All rights reserved.
//	

#import <Foundation/Foundation.h>

// Requests
#import "DWDenwenRequest.h"
#import "DWImageRequest.h"

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
 * Request the given page of the currently popular places
 */
- (void)requestPopularPlaces:(NSInteger)page;

/**
 * Request nearby places based on the user's current location
 */
- (void)requestNearbyPlaces;

/**
 * Request places followed by a specific user
 */
- (void)requestUserPlaces:(NSInteger)userID;

/**
 * Request a search query on the places table
 */
- (void)requestSearchPlaces:(NSString*)query;

/**
 * Send a request to create a new visit
 */
- (void)requestNewVisit;

/**
 * Download the image from the given URL
 */
- (void)requestImageAt:(NSString*)url 
				ofType:(NSInteger)imageType 
			   ownedBy:(NSInteger)ownerID;

@end