//
//  DWContainerViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWPlaceListViewController.h"


/**
 * Base class for containers which form the root views for
 * each of the tabs
 */
@interface DWContainerViewController : UIViewController <DWItemFeedViewControllerDelegate,DWPlaceListViewControllerDelegate> {
	UIViewController *customTabBarController;
}

/**
 * Init with a refernce to the custom tab bar controller
 */
- (id)initWithTabBarController:(UIViewController*)theCustomTabBarController;

/**
 * Indicates if the container child is on the currently
 * selected tab
 */
- (BOOL)isSelectedTab;


@end



