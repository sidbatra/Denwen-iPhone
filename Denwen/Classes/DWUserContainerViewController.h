//
//  DWUserContainerViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWContainerViewController.h"
#import "DWUserViewController.h"


#import "DWSession.h"
#import "DWConstants.h"


@interface DWUserContainerViewController : DWContainerViewController {
	DWUserViewController *userViewController;
}

@end

