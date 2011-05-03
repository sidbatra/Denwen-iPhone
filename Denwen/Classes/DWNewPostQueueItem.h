//
//  DWNewPostQueueItem.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DWCreationQueueItem.h"

@class DWItem;

/**
 * Queue item for creating a new post
 */
@interface DWNewPostQueueItem : DWCreationQueueItem {
	DWItem      *_item;
    UIImage     *_previewImage;
}

/**
 * The item object being posted
 */
@property (nonatomic,retain) DWItem *item;

/**
 * Preview image to be hooked to the attachment of
 * the final parsed DWItem object
 */
@property (nonatomic,retain) UIImage *previewImage;


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
        withVideoPreview:(UIImage*)videoPreviewImage
		  andOrientation:(NSString*)orientation 
			   toPlaceID:(NSInteger)placeID;

/**
 * Post item with optional image to a new place
 */
- (void)postWithItemData:(NSString*)data
	 withAttachmentImage:(UIImage*)image
			 toPlaceName:(NSString*)name
			  atLocation:(CLLocation*)location;

/**
 * Post item with optional video and orientation to a
 * new place
 */
- (void)postWithItemData:(NSString*)data
			withVideoURL:(NSURL*)url
        withVideoPreview:(UIImage*)videoPreviewImage
		  andOrientation:(NSString*)orientation
			 toPlaceName:(NSString*)name
			  atLocation:(CLLocation*)location;

@end

