//
//  DWUser.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWUser.h"
#import "DWSession.h"
#import "DWRequestsManager.h"
#import "UIImage+ImageProcessing.h"
#import "NSString+Helpers.h"
#import "DWConstants.h"

static NSString* const kImgSmallPlaceHolder				= @"user_small_placeholder.png";
static NSString* const kImgMediumPlaceHolder			= @"user_medium_placeholder.png";
static NSString* const kImgSignedInMediumPlaceHolder	= @"profile_button.png";
static NSString* const kDiskKeySignedInUser				= @"signedin_user_";
static NSString* const kDiskKeyID						= @"signedin_user__id";
static NSString* const kDiskKeyEmail					= @"signedin_user__email";
static NSString* const kDiskKeyPassword					= @"signedin_user__password";
static NSString* const kDiskKeyTwitterData				= @"signedin_user__twitterOAuthData";
static NSString* const kDiskKeyFacebookData				= @"signedin_user__facebookToken";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWUser

@synthesize firstName			= _firstName;
@synthesize lastName			= _lastName;
@synthesize email				= _email;
@synthesize encryptedPassword	= _encryptedPassword;
@synthesize smallURL			= _smallURL;
@synthesize mediumURL			= _mediumURL;
@synthesize smallPreviewImage	= _smallPreviewImage;
@synthesize	mediumPreviewImage	= _mediumPreviewImage;
@synthesize	hasPhoto			= _hasPhoto;
@synthesize twitterOAuthData	= _twitterOAuthData;
@synthesize	facebookAccessToken = _facebookAccessToken;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
		
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

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	if(_hasPhoto) {
		self.smallPreviewImage = nil;
		self.mediumPreviewImage = nil;
	}
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//NSLog(@"user released %d",_databaseID);
		
	self.firstName				= nil;
	self.lastName				= nil;
	self.email					= nil;
	self.encryptedPassword		= nil;
	self.twitterOAuthData		= nil;
	self.facebookAccessToken	= nil;
	
	if(_hasPhoto) {
		self.smallURL			= nil;
		self.mediumURL			= nil;		
		self.smallPreviewImage	= nil;
		self.mediumPreviewImage = nil;
	}
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isCurrentUser {
	return [[DWSession sharedDWSession] isActive] && 
				[DWSession sharedDWSession].currentUser.databaseID == self.databaseID;
}

//----------------------------------------------------------------------------------------------------
- (void)applyNewSmallImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgSmallUserLoaded
														object:nil
													  userInfo:info];
}

//----------------------------------------------------------------------------------------------------
- (void)applyNewMediumImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgMediumUserLoaded
														object:nil
													  userInfo:info];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)user {	
	[super populate:user];
	
	_databaseID			= [[user objectForKey:kKeyID] integerValue];
	
	self.firstName		= [user objectForKey:kKeyFirstName];
	self.lastName		= [user objectForKey:kKeyLastName];
	self.email			= [user objectForKey:kKeyEmail];
	
	if([user objectForKey:kKeyPhoto]) {
		NSDictionary *photo		= [user		objectForKey:kKeyPhoto];
        
        _hasPhoto               = YES;
		self.smallURL			= [photo	objectForKey:kKeySmallURL];
		self.mediumURL			= [photo	objectForKey:kKeyMediumURL];
		_isProcessed			= [[photo	objectForKey:kKeyIsProcessed] boolValue];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (BOOL)update:(NSDictionary*)user {
    if(![super update:user])
        return NO;
		
    self.email			= [user objectForKey:kKeyEmail];
    
    if([user objectForKey:kKeyPhoto]) {
        NSDictionary *photo		= [user objectForKey:kKeyPhoto];
        NSString *newSmallURL	= [photo objectForKey:kKeySmallURL]; 
        
        _hasPhoto               = YES;
        
        if(![self.smallURL isEqualToString:newSmallURL]) {
            self.smallURL		= newSmallURL;
            self.mediumURL		= [photo objectForKey:kKeyMediumURL];
            
            _isProcessed		= [[photo objectForKey:kKeyIsProcessed] boolValue];
            
            self.smallPreviewImage	= nil;
            self.mediumPreviewImage = nil;
        }
    }
    
    return YES;
}

//----------------------------------------------------------------------------------------------------
- (void)updatePreviewImages:(UIImage*)image {
	[self applyNewSmallImage:image];
	[self applyNewMediumImage:image];
}

//----------------------------------------------------------------------------------------------------
- (void)startSmallPreviewDownload {
	if(_hasPhoto && !_isSmallDownloading && !self.smallPreviewImage) {
		_isSmallDownloading = YES;
		
		[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.smallURL
												 withResourceID:self.databaseID
											successNotification:kNImgSmallUserLoaded
											  errorNotification:kNImgSmallUserError];
	}
	else if(!_hasPhoto){ 
		[self applyNewSmallImage:[UIImage imageNamed:kImgSmallPlaceHolder]];
	}
}


//----------------------------------------------------------------------------------------------------
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
			[self applyNewMediumImage:[UIImage imageNamed:kImgSignedInMediumPlaceHolder]];
		}
		else {
			[self applyNewMediumImage:[UIImage imageNamed:kImgMediumPlaceHolder]];
		}
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Read Write to NSUserDefaults

//----------------------------------------------------------------------------------------------------
- (void)storeTwitterData:(NSString *)data {
	
	self.twitterOAuthData = data;
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if(standardUserDefaults) {
		[standardUserDefaults setObject:self.twitterOAuthData forKey:kDiskKeyTwitterData];
		[standardUserDefaults synchronize];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)storeFacebookToken:(NSString *)token {
	
	self.facebookAccessToken = token;
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if(standardUserDefaults) {
		[standardUserDefaults setObject:self.facebookAccessToken forKey:kDiskKeyFacebookData];
		[standardUserDefaults synchronize];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)saveToDisk {	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setBool:YES						forKey:kDiskKeySignedInUser];
		[standardUserDefaults setInteger:_databaseID			forKey:kDiskKeyID];
		[standardUserDefaults setObject:self.email				forKey:kDiskKeyEmail];
		[standardUserDefaults setObject:self.encryptedPassword	forKey:kDiskKeyPassword];
		
		[standardUserDefaults synchronize];
	}
}

//----------------------------------------------------------------------------------------------------
- (BOOL)readFromDisk {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	BOOL status = NO;
	
	if (standardUserDefaults) {
		status = [standardUserDefaults boolForKey:kDiskKeySignedInUser];
		
		if(status) {			
			_databaseID					= [standardUserDefaults	integerForKey:kDiskKeyID];
			self.email					= [standardUserDefaults	objectForKey:kDiskKeyEmail];
			self.encryptedPassword		= [standardUserDefaults objectForKey:kDiskKeyPassword];
			self.twitterOAuthData		= [standardUserDefaults objectForKey:kDiskKeyTwitterData];
			self.facebookAccessToken	= [standardUserDefaults objectForKey:kDiskKeyFacebookData];
						
			[standardUserDefaults synchronize];
		}
	}
	
	return status;
}

//----------------------------------------------------------------------------------------------------
- (void)removeFromDisk {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		
		/**
		 * Removing the signed in user flag disables other methods from accessing the different stored fields
		 */
		[standardUserDefaults removeObjectForKey:kDiskKeySignedInUser];
		[standardUserDefaults synchronize];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (NSString*)fullName {
	return [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)mediumImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;

	self.mediumPreviewImage = [info objectForKey:kKeyImage];		
	_isMediumDownloading = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)mediumImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isMediumDownloading = NO;
}

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

@end
