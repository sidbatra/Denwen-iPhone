//
//  DWCreationQueue.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreationQueue.h"
#import "DWNewPostQueueItem.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

#include "SynthesizeSingleton.h"


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
- (void)addNewPostToQueueWithData:(NSString*)data 
			  withAttachmentImage:(UIImage*)image
						toPlaceID:(NSInteger)placeID {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[queueItem postWithItemData:data
			withAttachmentImage:image
					  toPlaceID:placeID];
	
	[self.queue addObject:queueItem];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPostToQueueWithData:(NSString*)data
					 withVideoURL:(NSURL*)url
					atOrientation:(NSString*)orientation
						toPlaceID:(NSInteger)placeID {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[queueItem postWithItemData:data 
				   withVideoURL:url
				 andOrientation:orientation
					  toPlaceID:placeID];
	
	[self.queue addObject:queueItem];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPostToQueueWithData:(NSString*)data
			  withAttachmentImage:(UIImage*)image
					  toPlaceName:(NSString*)name
					   atLocation:(CLLocation*)location {
	
	DWNewPostQueueItem *queueItem = [[[DWNewPostQueueItem alloc] init] autorelease];
	
	[queueItem postWithItemData:data 
			withAttachmentImage:image
					toPlaceName:name
					 atLocation:location];
	
	[self.queue addObject:queueItem];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)queueItemProcessed:(NSNotification*)notification {
	[self.queue removeObject:[notification object]];
}


@end
