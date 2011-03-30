//
//  DWUser.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUser.h"
#import "DWSession.h"


@implementation DWUser


@synthesize firstName=_firstName,lastName=_lastName,email=_email,encryptedPassword=_encryptedPassword,
			smallURL=_smallURL,mediumURL=_mediumURL,largeURL=_largeURL,smallPreviewImage=_smallPreviewImage,
			mediumPreviewImage=_mediumPreviewImage,smallConnection=_smallConnection,mediumConnection=_mediumConnection,
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
	}
	
	return self;  
}


#pragma mark -
#pragma mark Server interaction methods


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



// Update the place's preview urls using a place JSON object
//
- (void)updatePreviewURLs:(NSDictionary*)place {
	_hasPhoto = YES;
	
	NSDictionary *photo = [place objectForKey:@"photo"];
	
	self.smallURL = [photo objectForKey:@"small_url"];
	self.mediumURL = [photo objectForKey:@"medium_url"];
	self.largeURL = [photo objectForKey:@"large_url"];
}


// Resize and update preview images from the given image
//
- (void)updatePreviewImages:(UIImage*)image {
	self.smallPreviewImage = [image resizeTo:CGSizeMake(SIZE_USER_SMALL_IMAGE, SIZE_USER_SMALL_IMAGE)];
	self.mediumPreviewImage = [image resizeTo:CGSizeMake(SIZE_USER_MEDIUM_IMAGE, SIZE_USER_MEDIUM_IMAGE)];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:N_SMALL_USER_PREVIEW_DONE object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:N_MEDIUM_USER_PREVIEW_DONE object:self];
}


//Start the small file download
//
- (void)startSmallPreviewDownload {
	if(_hasPhoto && !_isSmallDownloading && !self.smallPreviewImage) {
		_isSmallDownloading = true;
		
		DWURLConnection *tempConnection = [[DWURLConnection alloc] initWithDelegate:self withInstanceID:0];
		self.smallConnection = tempConnection;
		[tempConnection release];
		
		[self.smallConnection fetchData:_smallURL withKey:[self smallUniqueKey] withCache:YES];
	}
	else if(!_hasPhoto){ 
		self.smallPreviewImage = [UIImage imageNamed:USER_SMALL_PLACEHOLDER_IMAGE_NAME];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_SMALL_USER_PREVIEW_DONE object:self];
	}
}


// Start the medium file download
//
- (void)startMediumPreviewDownload {
	if(_hasPhoto && !_isMediumDownloading && !self.mediumPreviewImage) {
		_isMediumDownloading = true;
		
		DWURLConnection *tempConnection = [[DWURLConnection alloc] initWithDelegate:self withInstanceID:1];
		self.mediumConnection = tempConnection;
		[tempConnection release];
		
		[self.mediumConnection fetchData:_mediumURL withKey:[self mediumUniqueKey] withCache:YES];
	}
	else if(!_hasPhoto){ 
		if([[DWSession sharedDWSession] isActive] && [DWSession sharedDWSession].currentUser.databaseID == self.databaseID)
			self.mediumPreviewImage = [UIImage imageNamed:USER_SIGNED_IN_MEDIUM_PLACEHOLDER_IMAGE_NAME];
		else	
			self.mediumPreviewImage = [UIImage imageNamed:USER_MEDIUM_PLACEHOLDER_IMAGE_NAME];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_MEDIUM_USER_PREVIEW_DONE object:self];
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
#pragma mark Caching helper functions


// Create and return a unique key for the small file
//
- (NSString*)smallUniqueKey {
	NSArray *listItems = [self.smallURL componentsSeparatedByString:@"/"];
	return [[[NSString alloc] initWithFormat:@"%@",[listItems objectAtIndex:[listItems count]-1]] autorelease];
}


// Create and return a unique key for the medium file
//
- (NSString*)mediumUniqueKey {
	NSArray *listItems = [self.mediumURL componentsSeparatedByString:@"/"];
	return [[[NSString alloc] initWithFormat:@"%@",[listItems objectAtIndex:[listItems count]-1]] autorelease];
}


// Create and return a unique key for the large file
//
- (NSString*)largeUniqueKey {
	NSArray *listItems = [self.largeURL componentsSeparatedByString:@"/"];
	return [[[NSString alloc] initWithFormat:@"%@",[listItems objectAtIndex:[listItems count]-1]] autorelease];
}



#pragma mark -
#pragma mark View helper functions


// Return the full name for the user
//
- (NSString*)fullName {
	return [[[NSString alloc] initWithFormat:@"%@ %@",self.firstName,self.lastName] autorelease];
}



#pragma mark -
#pragma mark URLConnection delegate


// Error while downloading data from the server. This also fires a delegate 
// error method which is handled by DWItem. 
//
- (void)errorLoadingData:(NSError *)error forInstanceID:(NSInteger)instanceID {

	//TODO: Handle or log image downloading error
	if(instanceID == 0) {
		self.smallConnection = nil;
		_isSmallDownloading = NO;
	}
	else {
		self.mediumConnection = nil;
		_isMediumDownloading = NO;
	}
}


// If the data is successfully downloaded from the server. This also fires a 
// delegate success method which is handled by DWItem.
//
- (void)finishedLoadingData:(NSMutableData *)data forInstanceID:(NSInteger)instanceID {	

	UIImage *image = [[UIImage alloc] initWithData:data];
	
	if(instanceID==0) {
		self.smallConnection = nil;
		
		self.smallPreviewImage = _isProcessed ? image : [image resizeTo:CGSizeMake(SIZE_USER_SMALL_IMAGE, SIZE_USER_SMALL_IMAGE)];
		
		_isSmallDownloading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_SMALL_USER_PREVIEW_DONE object:self];
	}
	else {
		self.mediumConnection = nil;
		
		self.mediumPreviewImage = _isProcessed ? image : [image resizeTo:CGSizeMake(SIZE_USER_MEDIUM_IMAGE, SIZE_USER_MEDIUM_IMAGE)];		
		_isMediumDownloading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_MEDIUM_USER_PREVIEW_DONE object:self];
	}
	
	[image release];
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
	
	//NSLog(@"user released %d",_databaseID);
	
	if(self.smallConnection) {
		[self.smallConnection cancel];
		self.smallConnection = nil;
	}
	
	if(self.mediumConnection) {
		[self.mediumConnection cancel];
		self.mediumConnection = nil;
	}
	
	
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
