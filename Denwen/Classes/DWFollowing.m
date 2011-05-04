//
//  DWFollowing.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFollowing.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFollowing

@synthesize databaseID = _databaseID;

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)following {
	_databaseID = [[following objectForKey:kKeyID] integerValue];
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[super dealloc];
}

@end
