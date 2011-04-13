//
//  DWPlace.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DWPoolObject.h"

@class DWAttachment;

/**
 * Place model represents a place entity as defined
 * in the database
 */
@interface DWPlace : DWPoolObject {
	NSString		*_name;
	NSString		*_hashedID;
	NSString		*_lastItemData;
	NSInteger		_lastItemDatabaseID;
	
	NSString		*_town;
	NSString		*_state;
	NSString		*_country;
	
	CLLocation		*_location;
	
	DWAttachment	*_attachment;
	
	NSInteger		_followersCount;
	
	BOOL			_hasAddress;
}

/**
 * Name of the place
 */
@property (nonatomic,copy) NSString *name;

/**
 * Unique ID for the place used in obfuscated URLs
 */
@property (nonatomic,copy) NSString *hashedID;

/**
 * Data entered with the last item created at the place
 */
@property (nonatomic,copy) NSString *lastItemData;

/**
 * Town in which the place is located
 */
@property (nonatomic,copy) NSString *town;

/**
 * State in which the place is located
 */
@property (nonatomic,copy) NSString *state;

/**
 * Country in which the place is located
 */
@property (nonatomic,copy) NSString *country;

/**
 * Geo location of the place
 */
@property (nonatomic,copy) CLLocation *location;

/**
 * Optional attachment of the last item posted at the place
 */
@property (nonatomic,retain) DWAttachment *attachment;


/**
 * Update the follower count by the given delta
 */
- (void)updateFollowerCount:(NSInteger)delta;
 
/**
 * Start downloading any images attachmented to the last item
 */
- (void)startPreviewDownload;

/**
 * Generate the display address for a place
 */
- (NSString*)displayAddress;

/**
 * Title text generated from the place's followers
 */
- (NSString*)titleText;

/**
 * Slice text used to preview the last item data
 */
- (NSString*)sliceText;

@end


