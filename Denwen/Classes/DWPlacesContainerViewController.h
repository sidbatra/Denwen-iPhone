//
//  DWPlacesContainerViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWContainerViewController.h"

@class DWPopularPlacesViewController;
@class DWSearchPlacesViewController;
@class DWNearbyPlacesViewController;
@class DWSegmentedControl;

/**
 * Primary view for the places tab and container for popular
 * and nearby places views
 */
@interface DWPlacesContainerViewController : DWContainerViewController {
	
	DWPopularPlacesViewController	*popularViewController;
	DWSearchPlacesViewController	*searchPlacesViewController;
	DWNearbyPlacesViewController	*nearbyViewController;
	
	DWSegmentedControl				*_segmentedControl;
}

/**
 * Segmented control on the nav bar to show choices to filter places
 */ 
@property (nonatomic,retain) DWSegmentedControl *segmentedControl;

@end

/**
 * Declaration for select private methods
 */
@interface DWPlacesContainerViewController (Private)
- (void)loadSelectedView:(NSInteger)currentSelectedIndex;	
@end