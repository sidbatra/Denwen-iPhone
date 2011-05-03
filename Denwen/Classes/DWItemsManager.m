//
//  DWItemsManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemsManager.h"
#import "DWMemoryPool.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemsManager

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_items = [[NSMutableArray alloc] init];	
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	for(DWItem *item in _items)
		[[DWMemoryPool sharedDWMemoryPool]  removeObject:item 
												   atRow:kMPItemsIndex];
	
    [_items release];
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)totalItems {
	return [_items count];
}

//----------------------------------------------------------------------------------------------------
- (DWItem *)getItem:(NSInteger)index {
	return index < [_items count] ? [_items objectAtIndex:index] : nil;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)getIDForLastItem {
    return [_items count] ? ((DWItem*)[_items lastObject]).databaseID : 0;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)getItemIDNotByUserID:(NSInteger)userID
                greaterThanItemID:(NSInteger)pivotItemID {
    
    NSInteger itemID = 0;
    
    for(DWItem *item in _items) {
        if(item.user.databaseID != userID && item.databaseID > pivotItemID) {
            itemID = item.databaseID;
            break;
        }
    }
    
    return itemID;
}

//----------------------------------------------------------------------------------------------------
- (void)clearAllItems {
	for(DWItem *item in _items)
		[[DWMemoryPool sharedDWMemoryPool]  removeObject:item 
												   atRow:kMPItemsIndex];
	
	[_items removeAllObjects];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Populate items

//----------------------------------------------------------------------------------------------------
- (void)addItem:(DWItem*)item 
		atIndex:(NSInteger)index {
	
	[_items insertObject:item 
				 atIndex:index];
	
	item.pointerCount++;
}

//----------------------------------------------------------------------------------------------------
-(void) populateItem:(NSDictionary*)item {
	DWItem *new_item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:item 
																			 atRow:kMPItemsIndex];
	[_items addObject:new_item];
}

//----------------------------------------------------------------------------------------------------
- (void)populateItems:(NSArray*)items {
	[self populateItems:items
			 withBuffer:NO 
			  withClear:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)populateItems:(NSArray*)items withBuffer:(BOOL)bufferStatus {
	[self populateItems:items
			 withBuffer:bufferStatus 
			  withClear:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)populateItems:(NSArray*)items
		   withBuffer:(BOOL)bufferStatus 
			withClear:(BOOL)clearItemsStatus {
	
	if(clearItemsStatus)
		[self clearAllItems];
	
	if(bufferStatus)
		[self populateItem:nil];
	
	for(NSDictionary *item in items)
		[self populateItem:item];
}


@end
