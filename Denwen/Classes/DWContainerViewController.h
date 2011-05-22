//
//  DWContainerViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWPlaceListViewController.h"
#import "DWSharingManager.h"

/**
 * Base class for containers which form the root views for
 * each of the tabs
 */
@interface DWContainerViewController : UIViewController <UINavigationControllerDelegate,DWItemFeedViewControllerDelegate,DWPlaceListViewControllerDelegate,DWSharingManagerDelegate> {
    
	UIViewController *customTabBarController;
    DWSharingManager *_sharingManager;
}

/**
 * Non-reained reference to the custom tab bar controller
 */
@property (nonatomic,assign) UIViewController *customTabBarController;

/**
 * Abstract all sharing related operations
 */
@property (nonatomic,retain) DWSharingManager *sharingManager;


/**
 * Indicates if the container child is on the currently
 * selected tab
 */
- (BOOL)isSelectedTab;


@end


/**
 * Declarations for private methods
 */
@interface DWContainerViewController(Private)
- (void)processLaunchURL:(NSString*)url;
@end
