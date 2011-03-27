//
//  DWNearbyItemsViewController.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWItemFeedViewController.h"
#import "DWRequestManager.h"
#import "DWSession.h"


@interface DWNearbyItemsViewController : DWItemFeedViewController {
}

- (id)initWithDelegate:(id)delegate;

- (void)viewIsSelected;
- (void)viewIsDeselected;


@end
