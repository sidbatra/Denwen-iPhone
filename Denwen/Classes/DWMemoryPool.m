//
//  DWMemoryPool.m
//  Denwen
//
//  Created by Siddharth Batra on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWMemoryPool.h"

NSMutableArray *memoryPool = nil;


@implementation DWMemoryPool

// Initialize the array used in the pool
//
+ (void)initPool {
	memoryPool = [[NSMutableArray alloc] initWithCapacity:TOTAL_POOL_CLASSES];
	
	// Add a NSMutableDictionary for each class whose objects utilize the memory pool
	//
	for(int i=0;i<TOTAL_POOL_CLASSES;i++) {
		NSMutableDictionary *poolForClass = [[NSMutableDictionary alloc] init];
		[memoryPool addObject:poolForClass];
		[poolForClass release];
	}
	
}


// Combines getObject and setObject
//
+ (DWPoolObject*)getOrSetObject:(NSDictionary*)objectJSON atRow:(NSInteger)row {
	
	NSInteger key = objectJSON ? [[objectJSON objectForKey:@"id"] integerValue] : 0;
	DWPoolObject *new_object = [DWMemoryPool getObject:key atRow:row];
	
	if(!new_object) {
		
		if(row == ITEMS_INDEX)
			new_object = [[DWItem alloc] init];		
		else if(row == PLACES_INDEX)
			new_object = [[DWPlace alloc] init];
		else if(row == USERS_INDEX)
			new_object = [[DWUser alloc] init];
		
		
		if(objectJSON)
			[new_object populate:objectJSON];
		
		[DWMemoryPool setObject:new_object atRow:row];
		[new_object release];		
	}
	else {
		new_object.pointerCount++;
		[new_object update:objectJSON];
	}
	
	return new_object;
}


// Returns the DWPoolObject with the given objectID at the given row
//
+ (DWPoolObject*)getObject:(NSInteger)objectID atRow:(NSInteger)row {
	NSString *objectIDString = [[NSString alloc] initWithFormat:@"%d",objectID];
	
	NSMutableDictionary *poolForClass = [memoryPool objectAtIndex:row];
	DWPoolObject *object = [poolForClass objectForKey:objectIDString];
	
	[objectIDString release];
	
	return object;
}


// Set the given pool object at the key corresponding to its database ID at the given row
//
+ (void)setObject:(DWPoolObject*)poolObject atRow:(NSInteger)row {
	NSString *objectIDString = [[NSString alloc] initWithFormat:@"%d",poolObject.databaseID];
	
	NSMutableDictionary *poolForClass = [memoryPool objectAtIndex:row];
	[poolForClass setObject:poolObject forKey:objectIDString];
	poolObject.pointerCount++;
	
	[objectIDString release];
}



// Reduce the poiner count for the given pool object and remove it if there are no more references
//
+ (void)removeObject:(DWPoolObject*)poolObject atRow:(NSInteger)row {

	poolObject.pointerCount--;
	
	if(poolObject.pointerCount <= 0) {
		
		NSString *objectIDString = [[NSString alloc] initWithFormat:@"%d",poolObject.databaseID];
		
		NSMutableDictionary *poolForClass = [memoryPool objectAtIndex:row];
		[poolForClass removeObjectForKey:objectIDString];
		
		[objectIDString release];
	}
}


// Iterate through the memory pool calling the freeMemory method of DWPoolObject
//
+ (void)freeMemory {
	for(int i=0;i<TOTAL_POOL_CLASSES;i++) {
		NSMutableDictionary *poolForClass = [memoryPool objectAtIndex:i];
		
		//Call free memory on all the objects of this row
		//
		for(DWPoolObject *poolObject in [poolForClass allValues]) {
			[poolObject freeMemory];
		}
	}
}



@end
