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
	
	NSString		*_smallURL;
	NSString		*_largeURL;
	
	CLLocation		*_location;

	UIImage			*_smallPreviewImage;
	UIImage			*_largePreviewImage;
	
	DWAttachment	*_attachment;
	
	NSInteger		_followersCount;
	
	BOOL			_isSmallDownloading;
	BOOL			_isLargeDownloading;
	
	BOOL			_hasPhoto;
	BOOL			_hasAddress;
	BOOL			_isProcessed;
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
 * URL for the small place preview image
 */
@property (nonatomic,copy) NSString *smallURL;

/**
 * URL for the large place preview image
 */
@property (nonatomic,copy) NSString *largeURL;

/**
 * Geo location of the place
 */
@property (nonatomic,copy) CLLocation *location;

/**
 * Image corresponding to the smallURL
 */
@property (nonatomic,retain) UIImage *smallPreviewImage;

/**
 * Image corresponding to the large URL
 */
@property (nonatomic,retain) UIImage *largePreviewImage;

/**
 * Optional attachment of the last item posted at the place
 */
@property (nonatomic,retain) DWAttachment *attachment;

/**
 * Flag for whether a photo has been added to the place profile
 */
@property (nonatomic,readonly) BOOL hasPhoto;

/**
 * Update the small and large preview images
 */
- (void)updatePreviewImages:(UIImage*)image;

/**
 * Update the follower count by the given delta
 */
- (void)updateFollowerCount:(NSInteger)delta;
 
/**
 * Start downloading the image at smallURL or provide a suitable
 * placeholder
 */
- (void)startSmallPreviewDownload;

/**
 * Start downloading the image at largeURl or provide a suitable
 * placeholder
 */
- (void)startLargePreviewDownload;

/**
 * Generate the display address for a place
 */
- (NSString*)displayAddress;

/**
 * Title text generated from the place's followers
 */
- (NSString*)titleText;

@end


