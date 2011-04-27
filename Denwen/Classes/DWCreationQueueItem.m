//
//  DWCreationQueueItem.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreationQueueItem.h"
#import "DWConstants.h"

static NSInteger const kStateMediaUploading		= 0;
static NSInteger const kStatePrimaryUploading	= 1;
static NSInteger const kStateFailed				= 2;
static NSInteger const kStateFinished			= 3;
static NSInteger const kTotalMediaRetries		= 25;
static NSInteger const kTotalPrimaryRetries		= 5;
static float	 const kMaxProgress				= 1.0;
static float	 const kMediaProgressFactor		= 0.9;

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreationQueueItem

@synthesize state			= _state;
@synthesize progress		= _progress;
@synthesize filename		= _filename;
@synthesize errorMessage	= _errorMessage;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		
		self.filename = kEmptyString;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediaUploadDone:) 
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
- (BOOL)isActive {
	return (_state == kStateMediaUploading || _state == kStatePrimaryUploading) && !_isSilent;
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isFailed {
	return _state == kStateFailed;
}

//----------------------------------------------------------------------------------------------------
- (void)postUpdate {
    if(!_isSilent) 
        [[NSNotificationCenter defaultCenter] postNotificationName:kNQueueItemProgressUpdated 
                                                            object:nil
                                                          userInfo:nil];
}

//----------------------------------------------------------------------------------------------------
- (void)startMediaUpload {
	_state = kStateMediaUploading;
}

//----------------------------------------------------------------------------------------------------
- (void)startPrimaryUpload {
	_state = kStatePrimaryUploading;
	
	[self postUpdate];
}

//----------------------------------------------------------------------------------------------------
- (void)start {
	_mediaUploadRetries		= 0;
	_primaryUploadRetries	= 0;
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadFinished:(NSString*)theFilename {
    self.filename  = theFilename;
}

//----------------------------------------------------------------------------------------------------
- (void)mediaUploadError {
	if(_mediaUploadRetries++ < kTotalMediaRetries)
		[self startMediaUpload];
	else {
		_state = kStateFailed;
		[self postUpdate];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)primaryUploadFinished {
	_progress	= kMaxProgress;
	[self postUpdate];
	
	_state		= kStateFinished;
		
	[[NSNotificationCenter defaultCenter] postNotificationName:kNCreationQueueItemProcessed 
														object:self];
}

//----------------------------------------------------------------------------------------------------
- (void)primaryUploadError {
	if(_primaryUploadRetries++ < kTotalPrimaryRetries)
		[self startPrimaryUpload];
	else {
		_state = kStateFailed;
		[self postUpdate];
	}
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


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ASIUploadProgressDelegate

//----------------------------------------------------------------------------------------------------
- (void)setProgress:(float)newProgress {
	_progress = newProgress * kMediaProgressFactor;
	
	[self postUpdate];
}


@end
