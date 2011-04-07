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
	DWPlacesManager *_placeManager;
}

/**
 * Holds the cached places
 */
@property (nonatomic,retain) DWPlacesManager *placesManager;

@end
