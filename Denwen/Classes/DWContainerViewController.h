//
//  DWContainerViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWPlaceListViewController.h"

#import "DWUserViewController.h"
#import "DWPlaceViewController.h"
#import "DWImageViewController.h"
#import "DWWebViewController.h"

#import "DWURLHelper.h"

@interface DWContainerViewController : UIViewController <DWItemFeedViewControllerDelegate,DWPlaceListViewControllerDelegate> {
	
}

- (BOOL)isSelectedTab;


@end



