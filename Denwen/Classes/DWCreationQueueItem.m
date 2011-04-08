//
//  DWCreationQueueItem.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreationQueueItem.h"
#import "DWConstants.h"

static NSString* const kEmptyString				= @"";
static NSInteger const kStateMediaUploading		= 0;
static NSInteger const kStatePrimaryUploading	= 1;
static NSInteger const kStateFailed				= 2;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreationQueueItem

@synthesize state			= _state;
@synthesize filename		= _filename;
@synthesize errorMessage	= _errorMessage;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		
		self.filename = kEmptyString;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediaUploaded:) 
													 name:kNS3UploadDone
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediaUploadError:) 
													 name:kNS3UploadError
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.filename		= nil;
	self.errorMessage	= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)startMediaUpload {
	_state = kStateMediaUploading;
}

//----------------------------------------------------------------------------------------------------
- (void)startPrimaryUpload {
	_state = kStatePrimaryUploading;
}

//----------------------------------------------------------------------------------------------------
- (void)start {
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadFinished:(NSString*)theFilename {
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadError {
	_state = kStateFailed;
}

//----------------------------------------------------------------------------------------------------
- (void)primaryUploadFinished {
}

//----------------------------------------------------------------------------------------------------
- (void)primaryUploadError {
	_state = kStateFailed;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadDone:(NSNotification*)notification {
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_mediaUploadID == resourceID) {
		[self mediaUploadFinished:[info objectForKey:kKeyFilename]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadError:(NSNotification*)notification {
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_mediaUploadID == resourceID) {
		[self mediaUploadError];
	}
	
}

@end
