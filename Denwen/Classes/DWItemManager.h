//
//  DWItemManager.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWItem.h"
#import "DWMemoryPool.h"

@interface DWItemManager : NSObject {
	NSMutableArray *_items;
}

- (DWItem *)getItem:(NSInteger)index;
- (NSInteger)totalItems;

- (void)addItem:(DWItem*)item atIndex:(NSInteger)index;


- (void)clearAllItems;

- (void)populateItems:(NSArray*)items;
- (void)populateItems:(NSArray*)items withBuffer:(BOOL)bufferStatus;
- (void)populateItems:(NSArray*)items withBuffer:(BOOL)bufferStatus withClear:(BOOL)clearItemsStatus;

@end
