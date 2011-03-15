//
//  DWPlace.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlace.h"


@implementation DWPlace

@synthesize name=_name,hashedId=_hashedId,smallURL=_smallURL,mediumURL=_mediumURL,largeURL=_largeURL,location=_location,
		smallPreviewImage=_smallPreviewImage,mediumPreviewImage=_mediumPreviewImage,largePreviewImage=_largePreviewImage,
		smallConnection=_smallConnection,mediumConnection=_mediumConnection,largeConnection=_largeConnection,hasPhoto=_hasPhoto,
		town=_town,state=_state,country=_country;



#pragma mark -
#pragma mark Initialization logic


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_isSmallDownloading = NO;
		_isMediumDownloading = NO;
		_isLargeDownloading = NO;
		
		_forceSmallDownloading = NO;
		_forceMediumDownloading = NO;
		_forceLargeDownloading = NO;
		
		_hasAddress = NO;
	}
	
	return self;  
}



#pragma mark -
#pragma mark Server interaction methods


// Populate place attributes from JSON object
// parsed into a NSDictionary object
//
- (void)populate:(NSDictionary*)place {	
	[super populate:place];
	
	_databaseID = [[place objectForKey:@"id"] integerValue];
	_hasPhoto = [[place objectForKey:@"has_photo"] boolValue];
	
	self.name = [place objectForKey:@"name"];
	self.hashedId = [place objectForKey:@"hashed_id"];
	_followersCount = [[place objectForKey:@"followings_count"] integerValue];
	
	CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:[[place objectForKey:@"latitude"] floatValue] 
							   longitude:[[place objectForKey:@"longitude"] floatValue]];
	self.location = tempLocation;
	[tempLocation release];
	
	
	if(_hasPhoto) {
		NSDictionary *photo = [place objectForKey:@"photo"];
		self.smallURL = [photo objectForKey:@"small_url"]; 
		self.mediumURL = [photo objectForKey:@"medium_url"];
		self.largeURL = [photo objectForKey:@"large_url"];
		_isProcessed = [[photo objectForKey:@"is_processed"] boolValue];
	}
	
	NSDictionary *address = [place objectForKey:ADDRESS_JSON_KEY];
	
	if (address) {
		_hasAddress = YES;
		self.town = [address objectForKey:@"short_town"];
		self.state = [address objectForKey:@"short_state"];
		self.country = [address objectForKey:@"short_country"];
	}


}


// Override the update method to check for changes to place name, location and preview images
//
- (void)update:(NSDictionary*)objectJSON {
	
	float interval = -[self.updatedAt timeIntervalSinceNow];
	
	if(interval > POOL_OBJECT_UPDATE_INTERVAL) {
		
		NSString *newName = [objectJSON objectForKey:@"name"];
		 
		 if(![self.name isEqualToString:newName])
			 self.name = newName;
		
		NSString *newHashedId = [objectJSON objectForKey:@"hashed_id"];
		
		if(![self.hashedId isEqualToString:newHashedId])
			self.hashedId = newHashedId;
		
		_followersCount = [[objectJSON objectForKey:@"followings_count"] integerValue];
		
		 
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
				 self.largePreviewImage = nil;
			 }
		 }
		
		NSDictionary *address = [objectJSON objectForKey:ADDRESS_JSON_KEY];
		
		if(!_hasAddress && address) {
			_hasAddress = YES;
			self.town = [address objectForKey:@"short_town"];
			self.state = [address objectForKey:@"short_state"];
			self.country = [address objectForKey:@"short_country"];			
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
	self.smallPreviewImage = [DWImageHelper resizeImage:image scaledToSize:CGSizeMake(SIZE_PLACE_SMALL_IMAGE, SIZE_PLACE_SMALL_IMAGE)];
	self.mediumPreviewImage = [DWImageHelper resizeImage:image scaledToSize:CGSizeMake(SIZE_PLACE_MEDIUM_IMAGE, SIZE_PLACE_MEDIUM_IMAGE)];
	self.largePreviewImage = [DWImageHelper resizeImage:image scaledToSize:CGSizeMake(SIZE_PLACE_LARGE_IMAGE, SIZE_PLACE_LARGE_IMAGE)];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:N_SMALL_PLACE_PREVIEW_DONE object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:N_MEDIUM_PLACE_PREVIEW_DONE object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:N_LARGE_PLACE_PREVIEW_DONE object:self];
}


// Update the follower count by the given amount
//
- (void)updateFollowerCount:(NSInteger)delta {
	_followersCount += delta;
}


//Start the small file download
//
- (void)startSmallPreviewDownload {
	if(_hasPhoto && !_isSmallDownloading && (!self.smallPreviewImage || _forceSmallDownloading)) {
		_isSmallDownloading = true;
		
		DWURLConnection *tempConnection = [[DWURLConnection alloc] initWithDelegate:self withInstanceID:0];
		self.smallConnection = tempConnection;
		[tempConnection release];
		
		[self.smallConnection fetchData:_smallURL withKey:[self smallUniqueKey] withCache:YES];
	}
	else if(!_hasPhoto){ 
		self.smallPreviewImage = [UIImage imageNamed:PLACE_SMALL_PLACEHOLDER_IMAGE_NAME];
	
		[[NSNotificationCenter defaultCenter] postNotificationName:N_SMALL_PLACE_PREVIEW_DONE object:self];
	}
}


//Start the medium file download
//
- (void)startMediumPreviewDownload {
	if(_hasPhoto && !_isMediumDownloading && (!self.mediumPreviewImage || _forceMediumDownloading)) {
		_isMediumDownloading = true;
		
		DWURLConnection *tempConnection = [[DWURLConnection alloc] initWithDelegate:self withInstanceID:1];
		self.mediumConnection = tempConnection;
		[tempConnection release];
		
		[self.mediumConnection fetchData:_mediumURL withKey:[self mediumUniqueKey] withCache:YES];
	}
	else if(!_hasPhoto) {
		self.mediumPreviewImage = [UIImage imageNamed:PLACE_MEDIUM_PLACEHOLDER_IMAGE_NAME];

		[[NSNotificationCenter defaultCenter] postNotificationName:N_MEDIUM_PLACE_PREVIEW_DONE object:self];
	}
}


//Start the large file download
//
- (void)startLargePreviewDownload {
	if(_hasPhoto && !_isLargeDownloading && (!self.largePreviewImage || _forceLargeDownloading)) {
		_isLargeDownloading = true;
		
		DWURLConnection *tempConnection = [[DWURLConnection alloc] initWithDelegate:self withInstanceID:2];
		self.largeConnection = tempConnection;
		[tempConnection release];
		
		[self.largeConnection fetchData:_largeURL withKey:[self largeUniqueKey] withCache:YES];
	}
	/*else if(!_hasPhoto) {
		self.largePreviewImage = [UIImage imageNamed:PLACE_LARGE_PLACEHOLDER_IMAGE_NAME];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_LARGE_PLACE_PREVIEW_DONE object:self];
	}*/
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


// Generates an autoreleased display address for the place
//
- (NSString*)displayAddress {
	NSString *result = nil;
	
	if(_hasAddress)
		result = [[[NSString alloc] initWithFormat:@"%@, %@",self.town,self.state] autorelease];
	else
		result = FINDING_LOCALITY_MSG;
	
	return result;
}


// Title text used on place view pages
//
- (NSString*)titleText {
	NSString *text = nil;
	
	if(_followersCount == 0)
		text = [NSString stringWithFormat:@"%@",_name];
	else if(_followersCount == 1)
		text = [NSString stringWithFormat:@"%d is following",_followersCount];
	else
		text = [NSString stringWithFormat:@"%d are following",_followersCount];
	
	return text;
}



#pragma mark -
#pragma mark DWURLConnectionDelegate


// Error while downloading data from the server. This also fires a delegate 
// error method which is handled by DWItem. 
//
- (void)errorLoadingData:(NSError *)error forInstanceID:(NSInteger)instanceID {
	
	//TODO: handle or log image download error
	if(instanceID == 0) {
		self.smallConnection = nil;
		_isSmallDownloading = NO;
		_forceSmallDownloading = NO;
	}
	else if(instanceID == 1) {
		self.mediumConnection = nil;
		_isMediumDownloading = NO;
		_forceMediumDownloading = NO;
	}
	else if(instanceID == 2) {
		self.largeConnection = nil;
		_isLargeDownloading = NO;
		_forceLargeDownloading = NO;
	}
}


// If the data is successfully downloaded from the server. This also fires a 
// delegate success method which is handled by DWItem.
//
- (void)finishedLoadingData:(NSMutableData *)data forInstanceID:(NSInteger)instanceID {	
	
	UIImage *image =  [[UIImage alloc] initWithData:data];
	
	if(instanceID==0) {
		self.smallConnection = nil;
		
		self.smallPreviewImage = _isProcessed ? image : [DWImageHelper resizeImage:image 
																 scaledToSize:CGSizeMake(SIZE_PLACE_SMALL_IMAGE,SIZE_PLACE_SMALL_IMAGE)];
		
		_isSmallDownloading = NO;
		_forceSmallDownloading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_SMALL_PLACE_PREVIEW_DONE object:self];
	}
	else if(instanceID==1) {
		self.mediumConnection = nil;
	
		self.mediumPreviewImage = _isProcessed ? image : [DWImageHelper resizeImage:image 
																	  scaledToSize:CGSizeMake(SIZE_PLACE_MEDIUM_IMAGE,SIZE_PLACE_MEDIUM_IMAGE)];
		
		_isMediumDownloading = NO;
		_forceMediumDownloading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_MEDIUM_PLACE_PREVIEW_DONE object:self];
	}
	else if(instanceID==2) {
		self.largeConnection = nil;
		
		self.largePreviewImage = _isProcessed ? image : [DWImageHelper resizeImage:image 
																	   scaledToSize:CGSizeMake(SIZE_PLACE_LARGE_IMAGE,SIZE_PLACE_LARGE_IMAGE)];
		
		_isLargeDownloading = NO;
		_forceLargeDownloading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_LARGE_PLACE_PREVIEW_DONE object:self];
	}

	[image release];
}



#pragma mark -
#pragma mark Memory Management


// Free small and medium preview images
//
- (void)freeMemory {
	if(_hasPhoto) {
		self.smallPreviewImage = nil;
		self.mediumPreviewImage = nil;
		self.largePreviewImage = nil;
	}
}


// Usual Memory Cleanup
// 
-(void)dealloc{
	
	//NSLog(@"place released %d",_databaseID);
		
	if(self.smallConnection) {
		[self.smallConnection cancel];
		self.smallConnection = nil;
	}
	
	if(self.mediumConnection) {
		[self.mediumConnection cancel];
		self.mediumConnection = nil;
	}
	
	if(self.largeConnection) {
		[self.largeConnection cancel];
		self.largeConnection = nil;
	}
	
	self.name = nil;
	self.hashedId = nil;
	self.town = nil;
	self.state = nil;
	self.country = nil;
	self.location = nil;
	
	if(_hasPhoto) {
		self.smallURL = nil;
		self.mediumURL = nil;
		self.largeURL = nil;
		
		self.smallPreviewImage = nil;
		self.mediumPreviewImage = nil;
		self.largePreviewImage = nil;
	}
	
	[super dealloc];
}


@end
