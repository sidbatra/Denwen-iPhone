//
//  DWPlacesContainerViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWNearbyPlacesViewController.h"
#import "DWPopularPlacesViewController.h"
#import "DWPlaceViewController.h"
#import "DWNewPlaceViewController.h"
#import "DWNewItemViewController.h"
#import "DWUserViewController.h"
#import "DWImageViewController.h"
#import "DWWebViewController.h"

#import "DWSessionManager.h"
#import "Constants.h"


@interface DWPlacesContainerViewController : UIViewController <DWItemFeedViewControllerDelegate,DWPlaceListViewControllerDelegate> {
	
	DWPopularPlacesViewController *popularViewController;
	DWNearbyPlacesViewController *nearbyViewController;
		
	int _currentSelectedSegmentIndex;
}

@end
