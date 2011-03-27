//
//  DWFollowedPlacesCache.h
//  Denwen
//
//  Created by Siddharth Batra on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWRequestManager.h"
#import "DWSession.h"

#import "SynthesizeSingleton.h"

@interface DWFollowedPlacesCache : NSObject {
	NSMutableArray *_places;
	NSInteger _retries;
	
	DWRequestManager *_requestManager;
}

+ (DWFollowedPlacesCache *)sharedDWFollowedPlacesCache;

@property (readonly) NSMutableArray *places;
@property (retain) DWRequestManager *requestManager;


- (void)loadPlaces;
- (void)populatePlaces:(NSArray*)newPlaces;
- (NSArray*)generateImmutablePlaces;



@end
