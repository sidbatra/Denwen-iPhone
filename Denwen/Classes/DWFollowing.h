//
//  DWFollowing.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Following model represents as an entity the
 * action of a user following a place - as defined in 
 * the database
 */
@interface DWFollowing : NSObject {
	NSInteger _databaseID;
}

/**
 * Primary key for the model
 */
@property (nonatomic,readonly) NSInteger databaseID;

/**
 * Populate the object using a JSON dictionary
 */
- (void)populate:(NSDictionary*)following;

@end
