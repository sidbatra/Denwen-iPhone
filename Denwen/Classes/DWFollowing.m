//
//  DWFollowing.m
//  Denwen
//
//  Created by Siddharth Batra on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWFollowing.h"


@implementation DWFollowing

@synthesize databaseID=_databaseID;


// Populate the following object from a NSDictionary obtained from JSON
//
- (void)populate:(NSDictionary*)following {
	_databaseID = [[following objectForKey:@"id"] integerValue];
}




#pragma mark -
#pragma mark Memory Management


// Usual Memory Cleanup
// 
-(void)dealloc{
	[super dealloc];
}

@end
