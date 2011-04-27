//
//  DWCreationQueue.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreationQueue.h"
#import "DWNewPostQueueItem.h"
#import "DWNewUserPhotoQueueItem.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

#include "SynthesizeSingleton.h"

static float kFinalPostUpdateDelay	= 0.5;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreationQueue

@synthesize queue = _queue;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWCreationQueue);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		self.queue = [NSMutableArray array];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(queueItemProcessed:) 
													 name:kNCreationQueueItemProcessed
												   object:nil];	
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(queueItemProgressUpdated:) 
													 name:kNQueueItemProgressUpdated
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.queue = nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)postUpdate {
	NSInteger	totalActive		= 0;
	NSInteger	totalFailed		= 0;
	float		totalProgress	= 0.0;
	
	for(DWCreationQueueItem *item in self.queue) {
		if([item isActive]) {
			totalActive++;
			totalProgress += item.progress;
		}
		else if([item isFailed])
			totalFailed++;
	}
		
	if(totalActive)
		totalProgress /= totalActive;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNCreationQueueUpdated 
														object:nil
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSNumber numberWithInt:totalActive],kKeyTotalActive,
																[NSNumber numberWithInt:totalFailed],kKeyTotalFailed,
																[NSNumber numberWithFloat:totalProgress],kKeyTotalProgress,
																 nil]];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPostToQueueWithData:(NSString*)data 
			  withAttachmentImage:(UIImage*)image
						toPlaceID:(NSInteger)placeID {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[self.queue addObject:queueItem];

	[queueItem postWithItemData:data
			withAttachmentImage:image
					  toPlaceID:placeID];	
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPostToQueueWithData:(NSString*)data
					 withVideoURL:(NSURL*)url
					atOrientation:(NSString*)orientation
						toPlaceID:(NSInteger)placeID {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[self.queue addObject:queueItem];

	[queueItem postWithItemData:data 
				   withVideoURL:url
				 andOrientation:orientation
					  toPlaceID:placeID];	
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPostToQueueWithData:(NSString*)data
			  withAttachmentImage:(UIImage*)image
					  toPlaceName:(NSString*)name
					   atLocation:(CLLocation*)location {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[self.queue addObject:queueItem];

	[queueItem postWithItemData:data 
			withAttachmentImage:image
					toPlaceName:name
					 atLocation:location];	
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPostToQueueWithData:(NSString*)data
					 withVideoURL:(NSURL*)url
					atOrientation:(NSString*)orientation
					  toPlaceName:(NSString*)name
					   atLocation:(CLLocation*)location {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[self.queue addObject:queueItem];

	[queueItem postWithItemData:data 
				   withVideoURL:url
				 andOrientation:orientation 
					toPlaceName:name
					 atLocation:location];	
}

//----------------------------------------------------------------------------------------------------
- (void)addNewUpdateUserPhotoToQueueWithUserID:(NSInteger)userID
                                      andImage:(UIImage*)theImage {
    
    DWNewUserPhotoQueueItem *queueItem = [[[DWNewUserPhotoQueueItem alloc] init] autorelease];
    
    [self.queue addObject:queueItem];
    
    [queueItem updatePhotoForUserWithID:userID
                               toImage:theImage];
}

//----------------------------------------------------------------------------------------------------
- (void)retryRequests {
	for(DWCreationQueueItem *item in self.queue) {
		if([item isFailed]) {
			[item start];
		}
	}
}

//----------------------------------------------------------------------------------------------------
- (void)deleteRequests {
	for(DWCreationQueueItem *item in self.queue) {
		if([item isFailed])
			[self.queue removeObject:item];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)queueItemProcessed:(NSNotification*)notification {
	[self.queue removeObject:[notification object]];	
	
	[self performSelector:@selector(postUpdate)
			   withObject:nil
			   afterDelay:kFinalPostUpdateDelay];
}

//----------------------------------------------------------------------------------------------------
- (void)queueItemProgressUpdated:(NSNotification*)notification {
	[self postUpdate];
}


@end
