//
//  DWNearbyPlacesViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWPlaceListViewController.h"

/**
 * Display places near the user's location
 */
@interface DWNearbyPlacesViewController : DWPlaceListViewController {
}

/**
 * Init with delegate to receive events when a place is selected
 */
- (id)initWithDelegate:(id)delegate;

@end
