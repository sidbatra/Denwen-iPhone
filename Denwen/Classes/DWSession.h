//
//  DWSession.h
//  Copyright 2011 Denwen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DWUser.h"
#import "SynthesizeSingleton.h"



/**
 * Manages the current user's session
 */
@interface DWSession : NSObject {
	DWUser			*_currentUser;
	CLLocation		*_location;
	BOOL			_refreshFollowedItems;
}

/**
 * Shared sole instance of the class
 */
+ (DWSession *)sharedDWSession;

/**
 * User object representing the current user
 */
@property (nonatomic,retain) DWUser* currentUser;

/**
 * Current location of the user
 */
@property (nonatomic,retain) CLLocation *location;

/**
 * Refresh flag for a user's followed items
 */
@property (nonatomic,assign) BOOL refreshFollowedItems;


/**
 * Read the user session from disk using NSUserDefaults
 */
- (void)read;

/**
 * Creae the user session with the given user object
 */
- (void)create:(DWUser*)newUser;

/**
 * Destroy the user session
 */
- (void)destroy;

/**
 * Test whether a user is currently signed in
 */
- (BOOL)isActive;


@end
