//
//  DWPlace.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlace.h"
#import "DWRequestsManager.h"



@implementation DWPlace

@synthesize name=_name,hashedId=_hashedId,smallURL=_smallURL,largeURL=_largeURL,location=_location,
		smallPreviewImage=_smallPreviewImage,largePreviewImage=_largePreviewImage,
		hasPhoto=_hasPhoto,
		town=_town,state=_state,country=_country;



#pragma mark -
#pragma mark Initialization logic


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_isSmallDownloading = NO;
		_isLargeDownloading = NO;
		_hasAddress			= NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallImageLoaded:) 
													 name:kNImgSmallPlaceLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallImageError:) 
													 name:kNImgSmallPlaceError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(largeImageLoaded:) 
													 name:kNImgLargePlaceLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(largeImageError:) 
													 name:kNImgLargePlaceError
												   object:nil];
		
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
	
	if(interval > kMPObjectUpdateInterval) {
		
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
				 self.largeURL = [photo objectForKey:@"large_url"];
				 _isProcessed = [[photo objectForKey:@"is_processed"] boolValue];
				 self.smallPreviewImage = nil;
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

- (void)applyNewSmallImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgSmallPlaceLoaded
														object:nil
													  userInfo:info];
}

- (void)applyNewLargeImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgLargePlaceLoaded
														object:nil
													  userInfo:info];
}


// Update the place's preview urls using a place JSON object
//
- (void)updatePreviewURLs:(NSDictionary*)place {
	_hasPhoto = YES;
	
	NSDictionary *photo = [place objectForKey:@"photo"];
	
	self.smallURL = [photo objectForKey:@"small_url"];
	self.largeURL = [photo objectForKey:@"large_url"];
}


// Resize and update preview images from the given image
//
- (void)updatePreviewImages:(UIImage*)image {
	[self applyNewSmallImage:image];
	[self applyNewLargeImage:image];
}


// Update the follower count by the given amount
//
- (void)updateFollowerCount:(NSInteger)delta {
	_followersCount += delta;
}


//Start the small file download
//
- (void)startSmallPreviewDownload {
	if(_hasPhoto && !_isSmallDownloading && !self.smallPreviewImage) {
		_isSmallDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.smallURL
												 withResourceID:self.databaseID
											successNotification:kNImgSmallPlaceLoaded
											  errorNotification:kNImgSmallPlaceError];
	}
	else if(!_hasPhoto){ 
		[self applyNewSmallImage:[UIImage imageNamed:PLACE_SMALL_PLACEHOLDER_IMAGE_NAME]];
	}
}


//Start the large file download
//
- (void)startLargePreviewDownload {
	if(_hasPhoto && !_isLargeDownloading && !self.largePreviewImage) {
		_isLargeDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.largeURL 
												 withResourceID:self.databaseID
		 									successNotification:kNImgLargePlaceLoaded
											  errorNotification:kNImgLargePlaceError];
	}
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


- (void)largeImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	self.largePreviewImage = [info objectForKey:kKeyImage];		
	_isLargeDownloading = NO;
}

- (void)largeImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isLargeDownloading = NO;
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
#pragma mark Memory Management


// Free small and medium preview images
//
- (void)freeMemory {
	if(_hasPhoto) {
		self.smallPreviewImage = nil;
		self.largePreviewImage = nil;
	}
}


// Usual Memory Cleanup
// 
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	//NSLog(@"place released %d",_databaseID);
	
	self.name = nil;
	self.hashedId = nil;
	self.town = nil;
	self.state = nil;
	self.country = nil;
	self.location = nil;
	
	if(_hasPhoto) {
		self.smallURL = nil;
		self.largeURL = nil;
		
		self.smallPreviewImage = nil;
		self.largePreviewImage = nil;
	}
	
	[super dealloc];
}


@end
