//
//  DWSession.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSession.h"

BOOL currentUserFollowedItemsRefresh = NO;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSession

@synthesize currentUser = _currentUser;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWSession);


//----------------------------------------------------------------------------------------------------
- (void)read {
	DWUser *user = [[DWUser alloc] init];
	
	if([user readFromDisk]) {
		self.currentUser = user;
		[self.currentUser print];
	}
	else {
		[user release];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (void)create:(DWUser*)newUser {
	self.currentUser = newUser;
	[self.currentUser saveToDisk];
}

//----------------------------------------------------------------------------------------------------
- (void)destroy {
	[self.currentUser removeFromDisk];
	self.currentUser = nil;
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isActive {
	return self.currentUser != nil;
}



@end
