//
//  DWFollowedPlacesCache.h
//  Denwen
//
//  Created by Siddharth Batra on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWRequestManager.h"
#import "DWSessionManager.h"

#import "SynthesizeSingleton.h"

@interface DWFollowedPlacesCache : NSObject {
	NSArray *_places;
	NSInteger _retries;
	
	DWRequestManager *_requestManager;
}

@property (retain) NSArray *places;


+ (DWFollowedPlacesCache *)sharedDWFollowedPlacesCache;

- (void)loadPlaces;

@end
