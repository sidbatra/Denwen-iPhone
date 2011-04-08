//
//  DWCreationQueue.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Queue for managing asynchronous creation
 */
@interface DWCreationQueue : NSObject {
	
	NSMutableArray *_queue;
}

/**
 * The sole shared instance of the class
 */
+ (DWCreationQueue *)sharedDWCreationQueue;

/**
 * Queue of items being created simultaneously
 */
@property (nonatomic,retain) NSMutableArray *queue;

/**
 * Create a new post with an optional image to an existing place
 */
- (void)addNewPostToQueueWithData:(NSString*)data 
			  withAttachmentImage:(UIImage*)image
						toPlaceID:(NSInteger)placeID;

/**
 * Create a new post with an optional video and orientation 
 * to an existing place
 */
- (void)addNewPostToQueueWithData:(NSString*)data
					 withVideoURL:(NSURL*)url
					atOrientation:(NSString*)orientation
						toPlaceID:(NSInteger)placeID;

@end
