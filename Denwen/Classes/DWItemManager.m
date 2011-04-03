//
//  DWItemManager.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemManager.h"
#import "DWConstants.h"

@interface DWItemManager ()
	-(void) populateItem:(NSDictionary*)item ;
@end


@implementation DWItemManager


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_items = [[NSMutableArray alloc] init];	
	}
	return self;  
}


// Retreive the item at the given index. 
//
- (DWItem *)getItem:(NSInteger)index {
	return index < [_items count] ? [_items objectAtIndex:index] : nil;
}


// Returns the total number of items
//
- (NSInteger)totalItems {
	return [_items count];
}

// Add an item at the given index
//
- (void)addItem:(DWItem*)item atIndex:(NSInteger)index {
	[_items insertObject:item atIndex:index];
	item.pointerCount++;
}


#pragma mark -
#pragma mark Item creation


// Deletes all the items 
//
- (void)clearAllItems {
	for(DWItem *item in _items)
		[[DWMemoryPool sharedDWMemoryPool]  removeObject:item atRow:kMPItemsIndex];
	
	[_items removeAllObjects];
}


// Calls the overloaded populateItems method with bufferStatus as NO
//
- (void)populateItems:(NSArray*)items {
	[self populateItems:items withBuffer:NO withClear:NO];
}


// Call the overloaded populateItems method withClearStatus NO
//
- (void)populateItems:(NSArray*)items withBuffer:(BOOL)bufferStatus {
	[self populateItems:items withBuffer:bufferStatus withClear:NO];
}


// Populates the items array from a body response dictionary and a bufferStatus
// to add an empty first entry
//
- (void)populateItems:(NSArray*)items withBuffer:(BOOL)bufferStatus withClear:(BOOL)clearItemsStatus {
	
	if(clearItemsStatus)
		[self clearAllItems];
	
	if(bufferStatus)
		[self populateItem:nil];
	
	for(NSDictionary *item in items)
		[self populateItem:item];
}


// Push an item into _items array using the memory pool
//
-(void) populateItem:(NSDictionary*)item {
	DWItem *new_item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:item atRow:kMPItemsIndex];
	[_items addObject:new_item];
}



#pragma mark -
#pragma mark Memory management


// The usual cleanup
//
- (void)dealloc {
	
	for(DWItem *item in _items)
		[[DWMemoryPool sharedDWMemoryPool]  removeObject:item atRow:kMPItemsIndex];
		
    [_items release];
	[super dealloc];
}

@end
