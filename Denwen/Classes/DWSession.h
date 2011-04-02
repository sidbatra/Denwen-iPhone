//
//  DWSession.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DWUser.h"

/**
 * Manages the current user's session
 */
@interface DWSession : NSObject {
	DWUser			*_currentUser;
	CLLocation		*_location;
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

/**
 * Tests the given userID with the current user' ID
 */
- (BOOL)doesCurrentUserHaveID:(NSInteger)userID;

@end
