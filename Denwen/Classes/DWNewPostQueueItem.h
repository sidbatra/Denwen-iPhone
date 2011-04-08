//
//  DWNewPostQueueItem.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWCreationQueueItem.h"

@class DWItem;

/**
 * Queue item for creating a new post
 */
@interface DWNewPostQueueItem : DWCreationQueueItem {
	DWItem *_item;
}

/**
 * The item object being posted
 */
@property (nonatomic,retain) DWItem *item;

/**
 * Post item with optional image to an existing place
 */
- (void)postWithItemData:(NSString*)data
	 withAttachmentImage:(UIImage*)image
			   toPlaceID:(NSInteger)placeID;

/**
 * Post item with optonal video and orientation to an 
 * existing place
 */
- (void)postWithItemData:(NSString*)data
			withVideoURL:(NSURL*)url
		  andOrientation:(NSString*)orientation 
			   toPlaceID:(NSInteger)placeID;

@end

