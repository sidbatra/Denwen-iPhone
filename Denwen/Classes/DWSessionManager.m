//
//  DWSessionManager.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWSessionManager.h"


DWUser *currentUser = nil;
BOOL currentUserFollowedItemsRefresh = NO;
BOOL currentUserFollowedPlacesRefresh = NO;


@implementation DWSessionManager


#pragma mark -
#pragma mark Session Creation & Deletion

// Checks NSUserDefaults for a saved copy of the iPhone owner's session
//
+ (void)checkDiskForSession {
	
	DWUser *user = [[DWUser alloc] init];
	
	BOOL status = [user readFromDisk];
	
	if(status) {
		currentUser = user;
		//[currentUser print];
		//[currentUser removeFromDisk];
	}
	else {
		[user release];
	}
	
}


// Creates a new session with the given user
+ (void)createSessionWithUser:(DWUser*)newUser {
	currentUser = newUser;
	[currentUser saveToDisk];
}


// Destroy the current active session
//
+ (void)destroyCurrentSession {
	[currentUser removeFromDisk];
	[currentUser release];
	currentUser = nil;
}



#pragma mark -
#pragma mark Session Retrieval


// Tests if a user is logged in or not
//
+ (BOOL)isSessionActive {
	return currentUser != nil;
}

@end
