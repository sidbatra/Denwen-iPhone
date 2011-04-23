//
//  DWAttachment.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWAttachment.h"
#import "DWRequestsManager.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"

static NSString* const kImgVideoPreviewPlaceholder		= @"video_placeholder.png";
static NSInteger const kSliceX							= 0;
static NSInteger const kSliceY							= 114;
static NSInteger const kSliceWidth						= 320;
static float	 const kSliceHeight						= 92;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWAttachment

@synthesize fileType		= _fileType;
@synthesize fileURL			= _fileURL;
@synthesize previewURL		= _previewURL;
@synthesize sliceURL		= _sliceURL;
@synthesize orientation		= _orientation;
@synthesize videoURL		= _videoURL;
@synthesize previewImage	= _previewImage;
@synthesize sliceImage		= _sliceImage;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumImageLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumImageError:) 
													 name:kNImgMediumAttachmentError
													object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(sliceImageLoaded:) 
													 name:kNImgSliceAttachmentLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(sliceImageError:) 
													 name:kNImgSliceAttachmentError
												   object:nil];
	}
	
	return self; 
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	self.previewImage	= nil;
	self.sliceImage		= nil;
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.fileURL		= nil;
	self.previewURL		= nil;
	self.sliceURL		= nil;
	self.orientation	= nil;
	self.videoURL		= nil;
	self.previewImage	= nil;
	self.sliceImage		= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)attachment {
	[super populate:attachment];
    
	_fileType			= [[attachment objectForKey:kKeyFileType] integerValue];
	_databaseID			= [[attachment objectForKey:kKeyID] integerValue];
	_isProcessed		= [[attachment objectForKey:kKeyIsProcessed] boolValue];
	
	self.fileURL		= [attachment objectForKey:kKeyActualURL];
	self.previewURL		= [attachment objectForKey:kKeyLargeURL];
	self.sliceURL		= [attachment objectForKey:kKeySliceURL];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)update:(NSDictionary*)attachment {
    if(![super update:attachment])
        return NO;
	
	if(!_isProcessed) {
		_isProcessed			= [[attachment objectForKey:kKeyIsProcessed] boolValue];
		
		if(_isProcessed) {
			self.previewURL		= [attachment objectForKey:kKeyLargeURL];
			self.sliceURL		= [attachment objectForKey:kKeySliceURL];
			self.previewImage	= nil;
			self.sliceImage		= nil;
		}
	}
    
    return YES;
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
- (void)appplyNewSliceImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgSliceAttachmentFinalized
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
			[self appplyNewPreviewImage:[UIImage imageNamed:kImgVideoPreviewPlaceholder]];
		}

	}

}

//----------------------------------------------------------------------------------------------------
- (void)startSliceDownload {
	if(!_isSliceDownloading && !self.sliceImage) {
		
		if(_isProcessed || [self isImage]) {
			_isSliceDownloading = YES;
			
			[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.sliceURL
													 withResourceID:self.databaseID
												successNotification:kNImgSliceAttachmentLoaded
												  errorNotification:kNImgSliceAttachmentError];
		}
	}
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
	
	self.previewImage	= [info objectForKey:kKeyImage];		
	_isDownloading		= NO;
}

//----------------------------------------------------------------------------------------------------
- (void)mediumImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isDownloading		= NO;
}

//----------------------------------------------------------------------------------------------------
- (void)sliceImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isSliceDownloading	= NO;
	
	
	if(!_isProcessed) {
		
		self.sliceImage = [info objectForKey:kKeyImage];
		
		if(self.sliceImage.size.width != kSliceWidth) {
			self.sliceImage = [self.sliceImage resizeTo:CGSizeMake(kSliceWidth,kSliceWidth)];
		}
		
		self.sliceImage = [self.sliceImage cropToRect:CGRectMake(kSliceX,kSliceY,kSliceWidth,kSliceHeight)];
	}
	else {
		self.sliceImage	= [info objectForKey:kKeyImage];
	}
	
	
	NSDictionary *userInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
							   self.sliceImage								,kKeyImage,
							   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgSliceAttachmentFinalized
														object:nil
													  userInfo:userInfo];
}

//----------------------------------------------------------------------------------------------------
- (void)sliceImageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isSliceDownloading		= NO;
}

@end
