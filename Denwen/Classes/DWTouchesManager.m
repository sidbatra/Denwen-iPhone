//
//  DWTouchesManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTouchesManager.h"
#import "DWRequestsManager.h"

#import "SynthesizeSingleton.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouchesManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DWTouchesManager);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		touches = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (BOOL)getTouchStatusForItemWithID:(NSInteger)itemID {
	return [touches objectForKey:[NSNumber numberWithInt:itemID]] != nil;
}

//----------------------------------------------------------------------------------------------------
- (void)createTouchForItemWithID:(NSInteger)itemID {
	
	if(![self getTouchStatusForItemWithID:itemID]) {
		
		[[DWRequestsManager sharedDWRequestsManager] createTouch:itemID];
		
		[touches setObject:[NSNumber numberWithBool:YES]
					forKey:[NSNumber numberWithInt:itemID]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[touches release];
	
	[super dealloc];
}



@end
