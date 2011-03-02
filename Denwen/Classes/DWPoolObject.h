//
//  DWPoolObject.h
//  Denwen
//
//  Created by Siddharth Batra on 2/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DWPoolObject : NSObject {
	NSInteger _databaseID;
	NSInteger _pointerCount;
	
	NSDate *_updatedAt;
}

@property (readonly) NSInteger databaseID;
@property (assign) NSInteger pointerCount;

@property (retain) NSDate *updatedAt;


- (void)populate:(NSDictionary*)result;
- (void)update:(NSDictionary*)objectJSON;

- (void)refreshUpdatedAt;

- (void)freeMemory;

@end
