//
//  DWMemoryPool.h
//  Denwen
//
//  Created by Siddharth Batra on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWItem.h"
#import "DWPlace.h"
#import "DWUser.h"
#import "DWPoolObject.h"
#import "DWConstants.h"

extern NSMutableArray *memoryPool;


@interface DWMemoryPool : NSObject {
}

+ (void)initPool;

+ (DWPoolObject*)getOrSetObject:(NSDictionary*)objectJSON atRow:(NSInteger)row;
+ (DWPoolObject*)getObject:(NSInteger)objectID atRow:(NSInteger)row;
+ (void)setObject:(DWPoolObject*)poolObject atRow:(NSInteger)row;
+ (void)removeObject:(DWPoolObject*)poolObject atRow:(NSInteger)row;

+ (void)freeMemory;

@end
