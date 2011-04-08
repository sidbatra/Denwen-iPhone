//
//  DWAttachment.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWAttachment.h"
#import "DWRequestsManager.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWAttachment

@synthesize databaseID		= _databaseID;
@synthesize fileType		= _fileType;
@synthesize fileURL			= _fileURL;
@synthesize previewURL		= _previewURL;
@synthesize orientation		= _orientation;
@synthesize videoURL		= _videoURL;
@synthesize previewImage	= _previewImage;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {		
		_isDownloading = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageError:) 
													 name:kNImgMediumAttachmentError
													object:nil];
	}
	
	return self; 
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	self.previewImage = nil;
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.fileURL		= nil;
	self.previewURL		= nil;
	self.orientation	= nil;
	self.videoURL		= nil;
	self.previewImage	= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)attachment {	
	_fileType			= [[attachment objectForKey:kKeyFileType] integerValue];
	_databaseID			= [[attachment objectForKey:kKeyID] integerValue];
	_isProcessed		= [[attachment objectForKey:kKeyIsProcessed] boolValue];
	
	self.fileURL		= [attachment objectForKey:kKeyActualURL];
	self.previewURL		= [attachment objectForKey:kKeyLargeURL];
}

//----------------------------------------------------------------------------------------------------
- (void)update:(NSDictionary*)attachment {
	
	if(!_isProcessed) {
		_isProcessed = [[attachment objectForKey:kKeyIsProcessed] boolValue];
		
		if(_isProcessed) {
			self.previewURL		= [attachment objectForKey:kKeyLargeURL];
			self.previewImage	= nil;
		}
	}
}

//----------------------------------------------------------------------------------------------------							  
- (BOOL)isVideo {
	return _fileType == kAttachmentVideo;
}


//----------------------------------------------------------------------------------------------------							  
- (BOOL)isImage {
	return _fileType == kAttachmentImage;
}

//----------------------------------------------------------------------------------------------------
- (void)appplyNewPreviewImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgMediumAttachmentLoaded
														object:nil
													  userInfo:info];
}

//----------------------------------------------------------------------------------------------------
- (void)startPreviewDownload {
	if(!_isDownloading && !self.previewImage) {
		
		if(_isProcessed || [self isImage]) {
			 _isDownloading = YES;
			
			[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.previewURL
													 withResourceID:self.databaseID
												successNotification:kNImgMediumAttachmentLoaded
												  errorNotification:kNImgMediumAttachmentError];
			
		}
		else {
			[self appplyNewPreviewImage:[UIImage imageNamed:VIDEO_PREVIEW_PLACEHOLDER_IMAGE_NAME]];
		}

	}

}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)imageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	self.previewImage = [info objectForKey:kKeyImage];		
	_isDownloading = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)imageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isDownloading = NO;
}

@end
