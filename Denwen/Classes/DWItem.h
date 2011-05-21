//
//  DWItem.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWPoolObject.h"
#import "DWAttachment.h"
#import "DWPlace.h"
#import "DWUser.h"

/**
 * Item model represents the item entity as represented
 * in the database. Each item needs a place, user and attachment
 * model to be properly displayed
 */
@interface DWItem : DWPoolObject {	
	NSString		*_data;
	
	NSInteger		_touchesCount;
	
	DWAttachment	*_attachment;
	DWPlace			*_place;
	DWUser			*_user;
	
	BOOL			_usesMemoryPool;
	BOOL			_isTouched;
	
	NSTimeInterval	_createdAtTimestamp;
}

/**
 * Data associated with the item in its condensed state
 * where URLs have been shortened
 */
@property (nonatomic,copy) NSString *data;

/**
 * Total touches on the item
 */
@property (nonatomic,readonly) NSInteger touchesCount;

/**
 * Attachment associated with the item
 */
@property (nonatomic,retain) DWAttachment *attachment;

/**
 * Place where the item was posted
 */
@property (nonatomic,retain) DWPlace *place;

/** 
 * The user who created the item
 */ 
@property (nonatomic,retain) DWUser *user;

/**
 * Indicates whether the item relies on the memory pool
 * for its members
 */
@property (nonatomic,assign) BOOL usesMemoryPool;

/**
 * Item has been touched by the current user or not
 */
@property (nonatomic,assign) BOOL isTouched;



/**
 * Add the given delta to the touches count
 */
- (void)touchesCountDelta:(NSInteger)delta;

/**
 * Timestamp representing in seconds the age of the item
 */
- (NSInteger)createdTimeAgoStamp;

/**
 * User friendly string for displaying the time when the
 * item was created
 */ 
- (NSString*)createdTimeAgoInWords;

/**
 * Launch download of the images needed to display the item
 */
- (void)startRemoteImagesDownload;

@end

