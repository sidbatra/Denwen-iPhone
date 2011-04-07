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
 * Holds the cached places
 */
@property (nonatomic,retain) DWPlacesManager *placesManager;

/**
 * Returns the cached nearby places
 */
- (NSMutableArray*)getNearbyPlaces;

@end
