//
//  DWSession.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSession.h"
#import "SynthesizeSingleton.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSession

@synthesize currentUser				= _currentUser;
@synthesize location				= _location;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWSession);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		[self read];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)read {
	DWUser *user = [[DWUser alloc] init];
	
	if([user readFromDisk]) {
		self.currentUser = user;
		//[self.currentUser print];
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

//----------------------------------------------------------------------------------------------------
- (BOOL)doesCurrentUserHaveID:(NSInteger)userID {
	return [self isActive] && self.currentUser.databaseID == userID;
}

@end
