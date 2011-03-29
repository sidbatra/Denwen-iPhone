//
//  DWFollowedItemsViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "DWItemFeedViewController.h"
#import "DWNotificationHelper.h"

#import "DWSession.h"
#import "DWRequestsManager.h"


@interface DWFollowedItemsViewController : DWItemFeedViewController {
}


- (id)initWithDelegate:(id)delegate;
- (void)viewIsSelected;
- (void)viewIsDeselected;

- (void)scrollToTop;

@end