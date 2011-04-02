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
#import "DWContainerViewController.h"
#import "DWNotificationHelper.h"

#import "DWSession.h"
#import "DWConstants.h"



@interface DWItemsContainerViewController : DWContainerViewController {
	DWFollowedItemsViewController *followedViewController;
	
	BOOL _isCurrentSelectedTab;
}

@end
