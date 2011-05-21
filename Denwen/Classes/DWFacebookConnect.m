//
//  DWFacebookConnect.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFacebookConnect.h"
#import "DWConstants.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFacebookConnect

@synthesize facebook    = _facebook;
@synthesize delegate    = _delegate;

//----------------------------------------------------------------------------------------------------
- (id)init {
    
    self = [super init];
    
    if(self) {
        self.facebook	= [[[Facebook alloc] initWithAppId:kFacebookAppID] autorelease];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.facebook   = nil;
    
    [super dealloc];
}

@end
