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
- (BOOL)update:(NSDictionary*)objectJSON {
    
	float   interval        =   -[self.updatedAt timeIntervalSinceNow];
    BOOL    updateNeeded    =   YES;
	
	if(interval <= kMPObjectUpdateInterval)
        updateNeeded = NO;
    else
        [self refreshUpdatedAt];
    
    return updateNeeded;
}

//----------------------------------------------------------------------------------------------------
- (void)refreshUpdatedAt {
	self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
