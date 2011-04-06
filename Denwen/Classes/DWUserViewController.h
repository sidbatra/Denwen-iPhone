//
//  DWUserViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWMediaPicker.h"
#import "DWUser.h"

#import "MBProgressHUD.h"

/**
 * Display details about a user and the items posted by them
 */
@interface DWUserViewController : DWItemFeedViewController <UIActionSheetDelegate,DWMediaPickerDelegate> {
	DWUser			*_user;
	NSInteger		_uploadID;
	DWMediaPicker	*_mediaPicker;
	MBProgressHUD	*_mbProgressIndicator;
}

/**
 * User object whose view is being displayed
 */
@property (nonatomic,retain) DWUser *user;

/**
 * Used to procure media from the user
 */
@property (nonatomic,retain) DWMediaPicker *mediaPicker;

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
