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
	NSArray			*_urls;
	
	DWAttachment	*_attachment;
	DWPlace			*_place;
	DWUser			*_user;
	
	BOOL			_fromFollowedPlace; 
	NSTimeInterval	_createdAtTimestamp;
}

/**
 * Data associated with the item in its condensed state
 * where URLs have been shortened
 */
@property (nonatomic,copy) NSString *data;

/**
 * Array of urls in the item data
 */
@property (nonatomic,copy) NSArray *urls;

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
 * Only used in a freshly created item to indiciate
 * whether it is posted to a place followed by a user or not
 */
@property (nonatomic,assign) BOOL fromFollowedPlace;

/**
 * Does the item have a media attachment
 */
- (BOOL)hasAttachment;

/**
 * User friendly string for displaying the time when the
 * item was created
 */ 
- (NSString *)createdTimeAgoInWords;

/**
 * Launch download of the images needed to display the item
 */
- (void)startRemoteImagesDownload;

@end

