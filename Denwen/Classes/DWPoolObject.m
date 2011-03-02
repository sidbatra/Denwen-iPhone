//
//  DWPoolObject.m
//  Denwen
//
//  Created by Siddharth Batra on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPoolObject.h"


@implementation DWPoolObject

@synthesize pointerCount=_pointerCount,databaseID=_databaseID,updatedAt=_updatedAt;


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_pointerCount = 0;
		_databaseID = 0;
	}
	
	return self;  
}


// Set the updated at date if its nil
//
- (void)populate:(NSDictionary *)result {
	if(!self.updatedAt)
		[self refreshUpdatedAt];
}


// Stub
//
- (void)update:(NSDictionary*)objectJSON {
}


// Refresh the updated at date
//
- (void)refreshUpdatedAt {
	self.updatedAt = [NSDate dateWithTimeIntervalSinceNow:0];
}


// Stub
//
- (void)freeMemory {
}


// dealloc cleanup
// 
- (void)dealloc {
	self.updatedAt = nil;
	
	[super dealloc];
}

@end
