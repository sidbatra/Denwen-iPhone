//
//  DWAttachment.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWAttachment.h"
#import "DWRequestsManager.h"


@implementation DWAttachment

@synthesize previewImage=_previewImage,fileUrl=_fileUrl,previewUrl=_previewUrl,databaseID=_databaseID;



#pragma mark -
#pragma mark Initialization logic


// Init the class along with its member variables 
//
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



#pragma mark -
#pragma mark Server interaction methods


// Populate attachment attributes from JSON object
// parsed into a NSDictionary object
//
- (void)populate:(NSDictionary*)attachment {	
	_fileType = [[attachment objectForKey:@"filetype"] integerValue];
	_databaseID = [[attachment objectForKey:@"id"] integerValue];
	_isProcessed = [[attachment objectForKey:@"is_processed"] boolValue];
	
	self.fileUrl = [attachment objectForKey:@"actual_url"];
	self.previewUrl = [attachment objectForKey:@"large_url"];
}


// Override the update method to check for changes to is_processed 
//
- (void)update:(NSDictionary*)objectJSON {
	
	if(!_isProcessed) {
		_isProcessed = [[objectJSON objectForKey:@"is_processed"] boolValue];
		
		if(_isProcessed) {
			self.previewUrl = [objectJSON objectForKey:@"large_url"];
			self.previewImage = nil;
		}
	}
}

- (void)appplyNewPreviewImage:(UIImage*)image {
	
	NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:self.databaseID]		,kKeyResourceID,
						   image										,kKeyImage,
						   nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNImgMediumAttachmentLoaded
														object:nil
													  userInfo:info];
}


//Start the attachment preview download
//
- (void)startPreviewDownload {
	if(!_isDownloading && !self.previewImage) {
		
		if(_isProcessed || [self isImage]) {
			 _isDownloading = YES;
			
			[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.previewUrl
													 withResourceID:self.databaseID
												successNotification:kNImgMediumAttachmentLoaded
												  errorNotification:kNImgMediumAttachmentError];
			
		}
		else {
			[self appplyNewPreviewImage:[UIImage imageNamed:VIDEO_PREVIEW_PLACEHOLDER_IMAGE_NAME]];
		}

	}

}


- (void)imageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	self.previewImage = [info objectForKey:kKeyImage];		
	_isDownloading = NO;
}


- (void)imageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != self.databaseID)
		return;
	
	_isDownloading = NO;
}




#pragma mark -
#pragma mark Preview Deciding functions


// Returns whether the upload requires an image preview from a
// remote server
//
- (BOOL)hasRemoteImagePreview {
	return _fileType == IMAGE || _fileType == VIDEO;
}


// Tests if the attachment is a video
//																  
- (BOOL)isVideo {
	return _fileType == VIDEO;
}
						
																  
// Tests if the attachment is an image
//																  
- (BOOL)isImage {
  return _fileType == IMAGE;
}
												


#pragma mark -
#pragma mark Memory Management


// Release the preview image
//
- (void)freeMemory {
	self.previewImage = nil;
}


// Usual Memory Cleanup
// 
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.fileUrl = nil;
	self.previewUrl = nil;
	self.previewImage = nil;
	
	[super dealloc];
}

@end
