//
//  DWPoolObject.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPoolObject.h"
#import "DWConstants.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPoolObject

@synthesize pointerCount	= _pointerCount;
@synthesize databaseID		= _databaseID;
@synthesize updatedAt		= _updatedAt;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_pointerCount	= 0;
		_databaseID		= kMPDefaultDatabaseID;
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.updatedAt = nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary *)result {
	if(!self.updatedAt)
		[self refreshUpdatedAt];
}

//----------------------------------------------------------------------------------------------------
- (void)update:(NSDictionary*)objectJSON {
}

//----------------------------------------------------------------------------------------------------
- (void)refreshUpdatedAt {
	self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
