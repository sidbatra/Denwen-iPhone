//
//  DWTouchesManager.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Manages creation, retrieval and existence checks for touches
 */
@interface DWTouchesManager : NSObject {
	NSMutableDictionary *touches;
}

/**
 * The sole shared instance of the class
 */
+ (DWTouchesManager *)sharedDWTouchesManager;


/**
 * Whether the given itemID has been touched or not
 */
- (BOOL)getTouchStatusForItemWithID:(NSInteger)itemID;

/**
 * Create a touch if this item hasn't been touched
 * by the current user
 */
- (void)createTouchForItemWithID:(NSInteger)itemID;

@end
