//
//  DWNewUserPhotoQueueItem.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNewUserPhotoQueueItem.h"
#import "DWRequestsManager.h"
#import "DWSession.h"
#import "DWuser.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNewUserPhotoQueueItem

@synthesize image   = _image;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
        
        _isSilent = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPhotoUpdated:) 
													 name:kNUserUpdated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPhotoUpdateError:) 
													 name:kNUserUpdateError
												   object:nil];		
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.image  = nil;
        
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)updatePhotoForUserWithID:(NSInteger)userID
                         toImage:(UIImage*)theImage {
    
    self.image  = theImage;
    _userID     = userID;
    
    [self start];
}


//----------------------------------------------------------------------------------------------------
- (void)startMediaUpload {
	[super startMediaUpload];
    
    _mediaUploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:self.image
                                                                             toFolder:kS3UsersFolder
                                                                   withUploadDelegate:nil];
}

//----------------------------------------------------------------------------------------------------
- (void)startPrimaryUpload {
	[super startPrimaryUpload];

	_primaryUploadID = [[DWRequestsManager sharedDWRequestsManager] updatePhotoForUserWithID:_userID
                                                                           withPhotoFilename:self.filename];
}

//----------------------------------------------------------------------------------------------------
- (void)start {
	[super start];
	
	if(self.image)
		[self startMediaUpload];
	else
		[self startPrimaryUpload];
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadFinished:(NSString*)theFilename {
	[super mediaUploadFinished:theFilename];
    
    self.image  = nil;
        
	[self startPrimaryUpload];
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadError {
	[super mediaUploadError];
}

//----------------------------------------------------------------------------------------------------
- (void)primaryUploadFinished {
	[super primaryUploadFinished];
}

//----------------------------------------------------------------------------------------------------
- (void)primaryUploadError {
	[super primaryUploadError];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)userPhotoUpdated:(NSNotification*)notification {
    NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_primaryUploadID != resourceID)
		return;
	
	NSDictionary *body = [info objectForKey:kKeyBody];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
        
        DWUser *user = [[DWSession sharedDWSession] currentUser];
        [user update:[body objectForKey:kKeyUser]];
        [user savePicturesToDisk];
        
        [self primaryUploadFinished];
    }
    else {
        [self primaryUploadError];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)userPhotoUpdateError:(NSNotification*)notification {
    NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_primaryUploadID != resourceID)
		return;
	    
    [self primaryUploadError];
}

@end
