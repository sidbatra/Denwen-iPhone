//
//  DWItemsManager.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWItem.h"

/**
 * Manages a group of items and abstracts their memeory management and retreival
 */
@interface DWItemsManager : NSObject {
	NSMutableArray *_items;
}

/**
 * Retrieve the total number of items
 */
- (NSInteger)totalItems;

/**
 * Retrieve the item at the given index
 */
- (DWItem*)getItem:(NSInteger)index;

/**
 * Returns the databaseID for the last item
 */
- (NSInteger)getIDForLastItem;

/**
 * Finds any new items not created by the given user ID
 */
- (NSInteger)getItemIDNotByUserID:(NSInteger)userID
                greaterThanItemID:(NSInteger)pivotItemID;

/**
 * Add the given item at the given index
 */
- (void)addItem:(DWItem*)item
		atIndex:(NSInteger)index;

/**
 * Call the overloaded populate items with
 * bufferStatus NO and clearItemsStatus NO
 */
- (void)populateItems:(NSArray*)items;

/**
 * Call the overloaded populate items with
 * clearItemsStatus as NO
 */
- (void)populateItems:(NSArray*)items
		   withBuffer:(BOOL)bufferStatus;

/**
 * Populate an entire array of items. bufferStatus
 * when set adds an empty entry at the first index.
 * clearItemsStatus controls replacing or appending
 * of items
 */
- (void)populateItems:(NSArray*)items 
		   withBuffer:(BOOL)bufferStatus 
			withClear:(BOOL)clearItemsStatus;

/**
 * Clear all items in the array and remove their references
 * from the memory pool
 */
- (void)clearAllItems;

@end
