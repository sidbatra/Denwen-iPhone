//
//  DWMemoryPool.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWPoolObject.h"

/**
 * Memory pool enables resuse of objects
 * of critical classes. Classes whose objects
 * use the memory pool must inherit from DWPoolObject
 */
@interface DWMemoryPool : NSObject {
	NSMutableArray *_memoryPool;
}

/**
 * The sole shared instance of the class
 */
+ (DWMemoryPool *)sharedDWMemoryPool;

/**
 * Each row in the array is assigned to a mutable dictionary
 * that holds objects of a particular class indexed by their
 * primary ids
 */
@property (nonatomic,retain) NSMutableArray *memoryPool;

/**
 * Test is there is an object with the primary key of the objectJSON
 * at the given row. If not then create a new object with the given
 * objectRow at the given row.
 */
- (DWPoolObject*)getOrSetObject:(NSDictionary*)objectJSON 
						  atRow:(NSInteger)row;

/**
 * Retreive the object at the given row with the given objectID
 * return nil if not found
 */
- (DWPoolObject*)getObject:(NSInteger)objectID
					 atRow:(NSInteger)row;

/**
 * Add the given pool object to the given row
 */
- (void)setObject:(DWPoolObject*)poolObject
			atRow:(NSInteger)row;

/**
 * Remove the pool object from the given row
 */
- (void)removeObject:(DWPoolObject*)poolObject
			   atRow:(NSInteger)row;

/**
 * Free non critical memory from all the pool objects
 */
- (void)freeMemory;

@end
