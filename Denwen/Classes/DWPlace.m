//
//  DWPlace.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlace.h"
#import "DWAttachment.h"
#import "DWRequestsManager.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"

static NSString* const kImgSmallPlaceHolder = @"place_small_placeholder.png";
static NSString* const kImgLargePlaceHolder = @"place_placeholder.png";
static NSString* const kMsgFindingLocality	= @"Finding locality";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlace

@synthesize name				= _name;
@synthesize hashedID			= _hashedID;
@synthesize lastItemData		= _lastItemData;
@synthesize smallURL			= _smallURL;
@synthesize largeURL			= _largeURL;
@synthesize location			= _location;
@synthesize smallPreviewImage	= _smallPreviewImage;
@synthesize largePreviewImage	= _largePreviewImage;
@synthesize attachment			= _attachment;
@synthesize hasPhoto			= _hasPhoto;
@synthesize	town				= _town;
@synthesize state				= _state;
@synthesize country				= _country;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
		
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

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	if(_hasPhoto) {
		self.smallPreviewImage = nil;
		self.largePreviewImage = nil;
	}
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//NSLog(@"place released %d",_databaseID);
	
	self.name					= nil;
	self.hashedID				= nil;
	self.lastItemData			= nil;
	self.town					= nil;
	self.state					= nil;
	self.country				= nil;
	self.location				= nil;
	
	if(_hasPhoto) {
		self.smallURL			= nil;
		self.largeURL			= nil;
		
		self.smallPreviewImage	= nil;
		self.largePreviewImage	= nil;
	}
	
	self.attachment				= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)place {	
	[super populate:place];
	
	_databaseID				= [[place objectForKey:kKeyID] integerValue];
	_hasPhoto				= [[place objectForKey:kKeyHasPhoto] boolValue];
	
	self.name				= [place objectForKey:kKeyName];
	self.hashedID			= [place objectForKey:kKeyHashedID];
	_followersCount			= [[place objectForKey:kKeyFollowingsCount] integerValue];
	
	self.location = [[[CLLocation alloc] initWithLatitude:[[place objectForKey:kKeyLatitude]  floatValue] 
												longitude:[[place objectForKey:kKeyLongitude] floatValue]] autorelease];
	
	if(_hasPhoto) {
		NSDictionary *photo = [place objectForKey:kKeyPhoto];
		
		self.smallURL		= [photo objectForKey:kKeySmallURL]; 
		self.largeURL		= [photo objectForKey:kKeyLargeURL];
		_isProcessed		= [[photo objectForKey:kKeyIsProcessed] boolValue];
	}
	
	NSDictionary *address = [place objectForKey:kKeyAddress];
	
	if (address) {
		_hasAddress		= YES;
		
		self.town		= [address objectForKey:kKeyShortTown];
		self.state		= [address objectForKey:kKeyShortState];
		self.country	= [address objectForKey:kKeyShortCountry];
	}
	
	NSDictionary *item = [place objectForKey:kKeyItem];
	
	if(item) {
		_lastItemDatabaseID	= [[item objectForKey:kKeyID] integerValue];
		self.lastItemData	= [item objectForKey:kKeyData];
				
		NSDictionary *itemAttachment = [item objectForKey:kKeyAttachment];	
		
		if(itemAttachment) {
			self.attachment = [[[DWAttachment alloc] init] autorelease];
			[self.attachment populate:itemAttachment];
		}
	}
}

//----------------------------------------------------------------------------------------------------
- (void)update:(NSDictionary*)place {
	
	float interval = -[self.updatedAt timeIntervalSinceNow];
	
	if(interval > kMPObjectUpdateInterval) {
		
		NSString *newName = [place objectForKey:kKeyName];
		 
		 if(![self.name isEqualToString:newName])
			 self.name = newName;
		
		NSString *newHashedID = [place objectForKey:kKeyHashedID];
		
		if(![self.hashedID isEqualToString:newHashedID])
			self.hashedID = newHashedID;
		
		_followersCount		= [[place objectForKey:kKeyFollowingsCount] integerValue];
		 _hasPhoto			= [[place objectForKey:kKeyHasPhoto]		boolValue];
		 
		 if(_hasPhoto) {
			 NSDictionary *photo	= [place objectForKey:kKeyPhoto];
			 NSString *newSmallURL	= [photo objectForKey:kKeySmallURL]; 
			 
			 if(![self.smallURL isEqualToString:newSmallURL]) {
				 self.smallURL				= newSmallURL;
				 self.largeURL				= [photo objectForKey:kKeyLargeURL];
				 
				 _isProcessed				= [[photo objectForKey:kKeyIsProcessed] boolValue];
				 
				 self.smallPreviewImage		= nil;
				 self.largePreviewImage		= nil;
			 }
		 }
		
		NSDictionary *address = [place objectForKey:kKeyAddress];
		
		if(!_hasAddress && address) {
			_hasAddress		= YES;
			
			self.town		= [address objectForKey:kKeyShortTown];
			self.state		= [address objectForKey:kKeyShortState];
			self.country	= [address objectForKey:kKeyShortCountry];		
		}
		
		NSDictionary *item = [place objectForKey:kKeyItem];
		
		if(item) {
			NSInteger newItemDatabaseID	= [[item objectForKey:kKeyID] integerValue];
	
			if(newItemDatabaseID != _lastItemDatabaseID) {
				
				_lastItemDatabaseID	= newItemDatabaseID;
				self.lastItemData	= [item objectForKey:kKeyData];
				
				
				NSDictionary *itemAttachment = [item objectForKey:kKeyAttachment];	
				
				if(itemAttachment) {
					self.attachment = [[[DWAttachment alloc] init] autorelease];
					[self.attachment populate:itemAttachment];
				}
				else
					self.attachment = nil;
			}
		}
		
		[self refreshUpdatedAt];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (NSString*)displayAddress {
	NSString *result = nil;
	
	if(_hasAddress)
		result = [NSString stringWithFormat:@"%@, %@",self.town,self.state];
	else
		result = kMsgFindingLocality;
	
	return result;
}

//----------------------------------------------------------------------------------------------------
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

//----------------------------------------------------------------------------------------------------
- (void)applyNewSmallImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgSmallPlaceLoaded
														object:nil
													  userInfo:info];
}

//----------------------------------------------------------------------------------------------------
- (void)applyNewLargeImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgLargePlaceLoaded
														object:nil
													  userInfo:info];
}

//----------------------------------------------------------------------------------------------------
- (void)updatePreviewImages:(UIImage*)image {
	[self applyNewSmallImage:image];
	[self applyNewLargeImage:image];
}

//----------------------------------------------------------------------------------------------------
- (void)updateFollowerCount:(NSInteger)delta {
	_followersCount += delta;
}

//----------------------------------------------------------------------------------------------------
- (void)startSmallPreviewDownload {
	if(_hasPhoto && !_isSmallDownloading && !self.smallPreviewImage) {
		_isSmallDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.smallURL
												 withResourceID:self.databaseID
											successNotification:kNImgSmallPlaceLoaded
											  errorNotification:kNImgSmallPlaceError];
	}
	else if(!_hasPhoto){ 
		[self applyNewSmallImage:[UIImage imageNamed:kImgSmallPlaceHolder]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)startLargePreviewDownload {
	if(_hasPhoto && !_isLargeDownloading && !self.largePreviewImage) {
		_isLargeDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.largeURL 
												 withResourceID:self.databaseID
		 									successNotification:kNImgLargePlaceLoaded
											  errorNotification:kNImgLargePlaceError];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)smallImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	self.smallPreviewImage = [info objectForKey:kKeyImage];		
	_isSmallDownloading = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)smallImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isSmallDownloading = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)largeImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	self.largePreviewImage = [info objectForKey:kKeyImage];		
	_isLargeDownloading = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)largeImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isLargeDownloading = NO;
}


@end
