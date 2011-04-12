//
//  DWPlacesContainerViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWContainerViewController.h"

@class DWPopularPlacesViewController;
@class DWNearbyPlacesViewController;
@class DWSegmentedControl;

/**
 * Primary view for the places tab and container for popular
 * and nearby places views
 */
@interface DWPlacesContainerViewController : DWContainerViewController {
	
	DWPopularPlacesViewController	*popularViewController;
	DWNearbyPlacesViewController	*nearbyViewController;
	
	DWSegmentedControl				*segmentedControl;
}


@end

/**
 * Declaration for select private methods
 */
@interface DWPlacesContainerViewController (Private)
- (void)loadSelectedView:(NSInteger)currentSelectedIndex;	
@end