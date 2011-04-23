//
//  DWMemoryPool.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWMemoryPool.h"
#import "DWItem.h"
#import "DWPlace.h"
#import "DWUser.h"
#import "DWConstants.h"

#import "SynthesizeSingleton.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWMemoryPool

@synthesize memoryPool = _memoryPool;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWMemoryPool);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		self.memoryPool = [NSMutableArray arrayWithCapacity:kMPTotalClasses];
		
		/** 
		 * Add a NSMutableDictionary for each class whose objects utilize the memory pool
		 */
		for(int i=0;i<kMPTotalClasses;i++) {
			[self.memoryPool addObject:[NSMutableDictionary dictionary]];
		}
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.memoryPool = nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (DWPoolObject*)getOrSetObject:(NSDictionary*)objectJSON 
						  atRow:(NSInteger)row {
	
	NSInteger key = objectJSON ? [[objectJSON objectForKey:kKeyID] integerValue] : 0;
	DWPoolObject *new_object = [[DWMemoryPool sharedDWMemoryPool]  getObject:key 
												 atRow:row];
	
	if(!new_object) {
		
		if(row == kMPItemsIndex)
			new_object = [[DWItem alloc] init];		
		else if(row == kMPPlacesIndex)
			new_object = [[DWPlace alloc] init];
		else if(row == kMPUsersIndex)
			new_object = [[DWUser alloc] init];
        else if(row == kMPAttachmentsIndex || row ==  kMPAttachmentSlicesIndex)
            new_object  = [[DWAttachment alloc] init];
        
		
		if(objectJSON)
			[new_object populate:objectJSON];
		
		[[DWMemoryPool sharedDWMemoryPool]  setObject:new_object atRow:row];
		[new_object release];		
	}
	else {
		new_object.pointerCount++;
		[new_object update:objectJSON];
	}
	
	return new_object;
}

//----------------------------------------------------------------------------------------------------
- (DWPoolObject*)getObject:(NSInteger)objectID 
					 atRow:(NSInteger)row {
	
	NSMutableDictionary *poolForClass = [self.memoryPool objectAtIndex:row];
	DWPoolObject *object = [poolForClass objectForKey:[NSString stringWithFormat:@"%d",objectID]];
	
	return object;
}

//----------------------------------------------------------------------------------------------------
- (void)setObject:(DWPoolObject*)poolObject atRow:(NSInteger)row {

	NSMutableDictionary *poolForClass = [self.memoryPool objectAtIndex:row];
	
	[poolForClass setObject:poolObject 
					 forKey:[NSString stringWithFormat:@"%d",poolObject.databaseID]];
	
	poolObject.pointerCount++;
}

//----------------------------------------------------------------------------------------------------
- (void)removeObject:(DWPoolObject*)poolObject atRow:(NSInteger)row {

	poolObject.pointerCount--;
	
	if(poolObject.pointerCount <= 0) {
		NSMutableDictionary *poolForClass = [self.memoryPool objectAtIndex:row];
		[poolForClass removeObjectForKey:[NSString stringWithFormat:@"%d",poolObject.databaseID]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	for(int i=0;i<kMPTotalClasses;i++) {
		NSMutableDictionary *poolForClass = [self.memoryPool objectAtIndex:i];
	
		for(DWPoolObject *poolObject in [poolForClass allValues]) {
			[poolObject freeMemory];
		}
	}
}

@end
