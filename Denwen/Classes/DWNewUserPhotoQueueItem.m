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

@synthesize image           = _image;
@synthesize imageClone      = _imageClone;

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
	self.image      = nil;
    self.imageClone = nil;
        
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private Methods
//----------------------------------------------------------------------------------------------------
- (void)sendUserProfilePicUpdatedNotification {
    
    if ([self isFailed])
        self.imageClone = nil;
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.imageClone, kKeyUserImage,
                          nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNUserProfilePicUpdated
                                                        object:nil
                                                      userInfo:info];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Profile Pic Upload/Update Methods
//----------------------------------------------------------------------------------------------------
- (void)updatePhotoForUserWithID:(NSInteger)userID
                         toImage:(UIImage*)theImage {
    
    self.image          = theImage;
    self.imageClone     = theImage;
    _userID             = userID;
    
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
    
    if ([self isFailed])
        [self sendUserProfilePicUpdatedNotification];
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
        
        [user updatePreviewImages:self.imageClone];
        [user savePicturesToDisk];
        
        [self sendUserProfilePicUpdatedNotification];
        [self primaryUploadFinished];
    }
    else {
        [self primaryUploadError];
        
        if ([self isFailed])
            [self sendUserProfilePicUpdatedNotification];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)userPhotoUpdateError:(NSNotification*)notification {
    NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_primaryUploadID != resourceID)
		return;
	    
    [self primaryUploadError];
    
    if ([self isFailed])
        [self sendUserProfilePicUpdatedNotification];
}

@end
