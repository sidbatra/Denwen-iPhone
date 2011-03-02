//
//  DWItemsContainerViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWFollowedItemsViewController.h"
#import "DWPlaceViewController.h"
#import "DWSelectPlaceViewController.h"
#import "DWUserViewController.h"
#import "DWImageViewController.h"
#import "DWWebViewController.h"
#import "DWNotificationHelper.h"

#import "DWSessionManager.h"
#import "Constants.h"



@interface DWItemsContainerViewController : UIViewController <DWItemFeedViewControllerDelegate> {
	DWFollowedItemsViewController *followedViewController;
	
	BOOL _isCurrentSelectedTab;
}

@end
