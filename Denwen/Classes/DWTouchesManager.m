//
//  DWTouchesManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTouchesManager.h"
#import "DWTouch.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouchesManager

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_touches = [[NSMutableArray alloc] init];	
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)totalTouches {
    return [_touches count];
}

//----------------------------------------------------------------------------------------------------
- (DWTouch*)getTouch:(NSInteger)index {
	return index < [_touches count] ? [_touches objectAtIndex:index] : nil;
}

//----------------------------------------------------------------------------------------------------
- (void)addTouch:(DWTouch*)touch
         atIndex:(NSInteger)index {
    
    [_touches insertObject:touch 
                   atIndex:index];
}

//----------------------------------------------------------------------------------------------------
- (void)clearAllTouches {
    [_touches removeAllObjects];
}

//----------------------------------------------------------------------------------------------------
- (void)populateTouches:(NSArray*)touches 
        withClearStatus:(BOOL)clearStatus {
    
    if(clearStatus)
        [self clearAllTouches];
	
	for(NSDictionary *touch in touches) {
		DWTouch *newTouch = [[[DWTouch alloc] init] autorelease];
        [newTouch populate:touch];
        
        [_touches addObject:newTouch];
    }
}

@end
