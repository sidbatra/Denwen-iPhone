//
//  DWPoolObject.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * PoolObject is a mandatory base class for all
 * objects that are added to the memory pool
 */
@interface DWPoolObject : NSObject {
	NSInteger	_databaseID;
	NSInteger	_pointerCount;
	
	NSDate		*_updatedAt;
}

/**
 * Primary key / unique id to uniquely identify the object
 */
@property (nonatomic,assign) NSInteger databaseID;

/**
 * Similar to retain count a count of the different places
 * the object is being used. An object is freed is the 
 * count drop below zero
 */
@property (nonatomic,assign) NSInteger pointerCount;

/**
 * Date when the object was last updated to avoid
 * slow down from duplicate or too frequent updates
 */
@property (nonatomic,retain) NSDate *updatedAt;

/**
 * Stub method overriden by the children classes
 * to populate their contents via a JSON dictionary
 */
- (void)populate:(NSDictionary*)objectJSON;

/**
 * Stub method overriden by the children classes
 * to update their contens via a JSON dictionary
 * Returns whether an updated was made or not
 */
- (BOOL)update:(NSDictionary*)objectJSON;

/**
 * Called by the child classes to refresh the udpated
 * timestamp after a successful update
 */
- (void)refreshUpdatedAt;

/**
 * Stub method overriden by the children classes to free
 * any non critical memory
 */
- (void)freeMemory;

@end
