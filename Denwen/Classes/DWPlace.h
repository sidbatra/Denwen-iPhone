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
 * Indicates presence of address
 */
@property (nonatomic,readonly) BOOL hasAddress;

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
@property (nonatomic,retain) CLLocation *location;

/**
 * Optional attachment of the last item posted at the place
 */
@property (nonatomic,retain) DWAttachment *attachment;



/**
 * Update the follower count by the given delta
 */
- (void)updateFollowerCount:(NSInteger)delta;

/**
 * Updates the address of the place via a address dictionary
 */
- (void)updateAddress:(NSDictionary*)address;
 
/**
 * Start downloading any images attachmented to the last item
 */
- (void)startPreviewDownload;

/**
 * Generate the display address for a place
 */
- (NSString*)displayAddress;

/**
 * Return the most specific address string in the order of
 * town -> state -> country -> ""
 */
- (NSString*)mostSpecificAddressString;

/**
 * Number of followers for the place
 */
- (NSInteger)followersCount;

@end


