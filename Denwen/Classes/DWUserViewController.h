//
//  DWUserViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWMediaPickerController.h"
#import "DWUser.h"

#import "MBProgressHUD.h"

@protocol DWMediaPickerControllerDelegate;

/**
 * Display details about a user and the items posted by them
 */
@interface DWUserViewController : DWItemFeedViewController <UIActionSheetDelegate,DWMediaPickerControllerDelegate> {
	DWUser			*_user;
	NSInteger		_uploadID;
	MBProgressHUD	*_mbProgressIndicator;
}

/**
 * User object whose view is being displayed
 */
@property (nonatomic,retain) DWUser *user;

/**
 * Progress indicator for displaying spinners 
 */
@property (nonatomic,retain) MBProgressHUD *mbProgressIndicator;

/**
 * Init with user whose view is being displayed and delegate
 * to receive item feed view delegate events - see DWItemFeedViewController
 */
- (id)initWithUser:(DWUser*)theUser 
	   andDelegate:(id)delegate;

@end
