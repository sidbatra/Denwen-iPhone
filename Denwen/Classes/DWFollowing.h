//
//  DWFollowing.h
//  Denwen
//
//  Created by Siddharth Batra on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DWFollowing : NSObject {
	NSInteger _databaseID;
}

@property (readonly) NSInteger databaseID;

- (void)populate:(NSDictionary*)following;

@end
