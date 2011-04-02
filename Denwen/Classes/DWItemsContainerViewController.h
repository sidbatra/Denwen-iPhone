//
//  DWItemsContainerViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWFollowedItemsViewController.h"
#import "DWContainerViewController.h"

/**
 * Primary view for the Feed tab and container for followed 
 * items view
 */
@interface DWItemsContainerViewController : DWContainerViewController {
	DWFollowedItemsViewController *followedViewController;
}

@end


/**
 * Declarations for select private methods
 */
@interface DWItemsContainerViewController(Private)

/**
 * Resets the badge value on the feeds tab
 * and uses notifications helper to reset count on the server
 * and the application icon
 */
- (void)resetBadgeValue;
@end
