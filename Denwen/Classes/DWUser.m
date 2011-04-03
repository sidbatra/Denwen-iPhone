//
//  DWUser.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUser.h"
#import "DWSession.h"
#import "DWRequestsManager.h"



@implementation DWUser


@synthesize firstName=_firstName,lastName=_lastName,email=_email,encryptedPassword=_encryptedPassword,
			smallURL=_smallURL,mediumURL=_mediumURL,largeURL=_largeURL,smallPreviewImage=_smallPreviewImage,
			mediumPreviewImage=_mediumPreviewImage,
			hasPhoto=_hasPhoto,twitterOAuthData=_twitterOAuthData,
			facebookAccessToken=_facebookAccessToken;



#pragma mark -
#pragma mark Initialization logic


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_isSmallDownloading = NO;
		_isMediumDownloading = NO;		
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallImageLoaded:) 
													 name:kNImgSmallUserLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallImageError:) 
													 name:kNImgSmallUserError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumImageLoaded:) 
													 name:kNImgMediumUserLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumImageError:) 
													 name:kNImgMediumUserError
												   object:nil];
	}
	
	return self;  
}


#pragma mark -
#pragma mark Server interaction methods

- (BOOL)isCurrentUser {
	return [[DWSession sharedDWSession] isActive] && 
				[DWSession sharedDWSession].currentUser.databaseID == self.databaseID;
}

- (void)applyNewSmallImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgSmallUserLoaded
														object:nil
													  userInfo:info];
}

- (void)applyNewMediumImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgMediumUserLoaded
														object:nil
													  userInfo:info];
}

// Populate user attributes from JSON object
// parsed into a NSDictionary object
//
- (void)populate:(NSDictionary*)user {	
	[super populate:user];
	
	_databaseID = [[user objectForKey:@"id"] integerValue];
	_hasPhoto = [[user objectForKey:@"has_photo"] boolValue];
	
	self.firstName = [user objectForKey:@"first_name"];
	self.lastName = [user objectForKey:@"last_name"];
	self.email = [user objectForKey:@"email"];
	
	if(_hasPhoto) {
		NSDictionary *photo = [user objectForKey:@"photo"];
		self.smallURL = [photo objectForKey:@"small_url"];
		self.mediumURL = [photo objectForKey:@"medium_url"];
		self.largeURL = [photo objectForKey:@"large_url"];
		_isProcessed = [[photo objectForKey:@"is_processed"] boolValue];
	}
	
}



// Override the update method to check for changes to member variables
//
- (void)update:(NSDictionary*)objectJSON {
	
	float interval = -[self.updatedAt timeIntervalSinceNow];
	
	if(interval > POOL_OBJECT_UPDATE_INTERVAL) {
		
		_hasPhoto = [[objectJSON objectForKey:@"has_photo"] boolValue];
		
		if(_hasPhoto) {
			NSDictionary *photo = [objectJSON objectForKey:@"photo"];
			NSString *newSmallURL = [photo objectForKey:@"small_url"]; 
			
			if(![self.smallURL isEqualToString:newSmallURL]) {
				self.smallURL = newSmallURL;
				self.mediumURL = [photo objectForKey:@"medium_url"];
				self.largeURL = [photo objectForKey:@"large_url"];
				_isProcessed = [[photo objectForKey:@"is_processed"] boolValue];
				self.smallPreviewImage = nil;
				self.mediumPreviewImage = nil;
			}
		}
		
		[self refreshUpdatedAt];
	}
	
}


// Resize and update preview images from the given image
//
- (void)updatePreviewImages:(UIImage*)image {
	[self applyNewSmallImage:image];
	[self applyNewMediumImage:image];
}


//Start the small file download
//
- (void)startSmallPreviewDownload {
	if(_hasPhoto && !_isSmallDownloading && !self.smallPreviewImage) {
		_isSmallDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.smallURL
												 withResourceID:self.databaseID
											successNotification:kNImgSmallUserLoaded
											  errorNotification:kNImgSmallUserError];
	}
	else if(!_hasPhoto){ 
		[self applyNewSmallImage:[UIImage imageNamed:USER_SMALL_PLACEHOLDER_IMAGE_NAME]];
	}
}


// Start the medium file download
//
- (void)startMediumPreviewDownload {
	if(_hasPhoto && !_isMediumDownloading && !self.mediumPreviewImage) {
		_isMediumDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.mediumURL 
												 withResourceID:self.databaseID
		 									successNotification:kNImgMediumUserLoaded
											  errorNotification:kNImgMediumUserError];
	}
	else if(!_hasPhoto){ 
		if([self isCurrentUser]) {
			[self applyNewMediumImage:[UIImage imageNamed:USER_SIGNED_IN_MEDIUM_PLACEHOLDER_IMAGE_NAME]];
		}
		else {
			[self applyNewMediumImage:[UIImage imageNamed:USER_MEDIUM_PLACEHOLDER_IMAGE_NAME]];
		}
	}
}




//=============================================================================================================================
#pragma mark -
#pragma mark Twitter interaction methods


// Store the Twitter OAuth data as a member variable and on disk
//
- (void)storeTwitterData:(NSString *)data {
	
	self.twitterOAuthData = data;
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if(standardUserDefaults) {
		[standardUserDefaults setObject:self.twitterOAuthData forKey:[NSString stringWithFormat:@"%@_twitterOAuthData",CURRENT_USER_KEY]];
		[standardUserDefaults synchronize];
	}
}


// Store the Facebook access token as a member variable and on disk
//
- (void)storeFacebookToken:(NSString *)token {
	
	self.facebookAccessToken = token;
	
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if(standardUserDefaults) {
		[standardUserDefaults setObject:self.facebookAccessToken forKey:[NSString stringWithFormat:@"%@_facebookToken",CURRENT_USER_KEY]];
		[standardUserDefaults synchronize];
	}
}



#pragma mark -
#pragma mark Methods to read and write the user object from NSUserDefault

// Saves a user piece by piece to the NSUserDefaults
//
- (void)saveToDisk {	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setBool:YES forKey:CURRENT_USER_KEY];
		[standardUserDefaults setInteger:_databaseID forKey:[NSString stringWithFormat:@"%@_id",CURRENT_USER_KEY]];
		[standardUserDefaults setObject:self.email forKey:[NSString stringWithFormat:@"%@_email",CURRENT_USER_KEY]];
		[standardUserDefaults setObject:self.encryptedPassword forKey:[NSString stringWithFormat:@"%@_password",CURRENT_USER_KEY]];
		
		[standardUserDefaults synchronize];
	}
}


// Populates a user piece by piece from the NSUserDefaults
//
- (BOOL)readFromDisk {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	BOOL status = NO;
	
	if (standardUserDefaults) {
		status = [standardUserDefaults boolForKey:CURRENT_USER_KEY];
		
		if(status) {			
			_databaseID = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"%@_id",CURRENT_USER_KEY]];
			self.email = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"%@_email",CURRENT_USER_KEY]];
			self.encryptedPassword = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"%@_password",CURRENT_USER_KEY]];
			self.twitterOAuthData = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"%@_twitterOAuthData",CURRENT_USER_KEY]];
			self.facebookAccessToken = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"%@_facebookToken",CURRENT_USER_KEY]];
						
			[standardUserDefaults synchronize];
		}
	}
	
	return status;
}


// Removes the user object from disk
//
- (void)removeFromDisk {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		
		// Removing the flag disables other methods from accessing the different stored fields
			[standardUserDefaults removeObjectForKey:CURRENT_USER_KEY];
			[standardUserDefaults synchronize];
	}
	
}


// Prints debugging info about the user object
//
-(void)print {
	//NSLog(@"%d\n %@\n %@\n %@\n %@\n %@\n %@\n %@\n %@",_databaseID,self.firstName,self.lastName,self.email,self.encryptedPassword,
	//	  self.smallURL,self.mediumURL,self.largeURL,self.twitterOAuthData);
	NSLog(@"%d\n %@\n %@\n %@\n",_databaseID,self.email,self.encryptedPassword,self.twitterOAuthData);
}



#pragma mark -
#pragma mark View helper functions


// Return the full name for the user
//
- (NSString*)fullName {
	return [[[NSString alloc] initWithFormat:@"%@ %@",self.firstName,self.lastName] autorelease];
}



#pragma mark -
#pragma mark Notifications

- (void)mediumImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;

	self.mediumPreviewImage = [info objectForKey:kKeyImage];		
	_isMediumDownloading = NO;
}

- (void)mediumImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isMediumDownloading = NO;
}

- (void)smallImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	self.smallPreviewImage = [info objectForKey:kKeyImage];		
	_isSmallDownloading = NO;
}

- (void)smallImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isSmallDownloading = NO;
}




//=============================================================================================================================
#pragma mark -
#pragma mark Memory Management


// Free small and medium preview images
//
- (void)freeMemory {
	if(_hasPhoto) {
		self.smallPreviewImage = nil;
		self.mediumPreviewImage = nil;
	}
}


// Usual Memory Cleanup
// 
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//NSLog(@"user released %d",_databaseID);

	
	self.firstName = nil;
	self.lastName = nil;
	self.email = nil;
	self.encryptedPassword = nil;
	self.twitterOAuthData = nil;
	self.facebookAccessToken = nil;
	
	if(_hasPhoto) {
		self.smallURL = nil;
		self.mediumURL = nil;
		self.largeURL = nil;
		
		self.smallPreviewImage = nil;
		self.mediumPreviewImage = nil;
	}
		
		
	[super dealloc];
}


@end
