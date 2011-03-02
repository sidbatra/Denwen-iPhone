//
//  ContainerView.h
//  Test
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GItemsViewController.h"
#import "GFollowedViewController.h"
#import "GPopularViewController.h"


@interface GContainerView : UIViewController {
	GItemsViewController *firstController;
	GFollowedViewController *secondController;
	GFollowedViewController *thirdController;
	NSInteger previousSelection;
}

@end
