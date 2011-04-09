//
//  DWPlacesCache.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWPlacesManager.h"

/**
 * Cache for groups of places used across the application
 */
@interface DWPlacesCache : NSObject {
	DWPlacesManager		*_placesManager;
	BOOL				_refreshNearbyPlacesOnNextLocationUpdate;
	BOOL				_nearbyPlacesReady;
	BOOL				_followedPlacesReady;
}

/**
 * The sole shared instance of the class
 */
+ (DWPlacesCache *)sharedDWPlacesCache;

/**
 * Indicates whether nearby places have been loaded once
 */
@property (nonatomic,readonly) BOOL nearbyPlacesReady;

/**
 * Indicates whether followed places have been loaded once
 */
@property (nonatomic,readonly) BOOL followedPlacesReady;

/**
 * Holds the cached places
 */
@property (nonatomic,retain) DWPlacesManager *placesManager;

/**
 * Tests if the given place is followed by the current user
 */
- (BOOL)isFollowedPlace:(DWPlace*)thePlace;

/**
 * Returns the cached array of nearby places
 */
- (NSMutableArray*)getNearbyPlaces;

/**
 * Returns the cache array of followed places
 */
- (NSMutableArray*)getFollowedPlaces;

@end
