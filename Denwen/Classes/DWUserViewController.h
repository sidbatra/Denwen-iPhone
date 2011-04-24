//
//  DWUserViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWMediaPickerController.h"
#import "DWUserTitleView.h"
#import "DWUser.h"


@protocol DWMediaPickerControllerDelegate;

/**
 * Display details about a user and the items posted by them
 */
@interface DWUserViewController : DWItemFeedViewController {
	DWUser              *_user;
    DWUserTitleView     *_userTitleView;
    
    NSInteger           _uploadID;
}

/**
 * User object whose view is being displayed
 */
@property (nonatomic,retain) DWUser *user;

/**
 * Subview for displaying username and following count
 */
@property (nonatomic,retain) DWUserTitleView *userTitleView;

/**
 * Init with user whose view is being displayed and delegate
 * to receive item feed view delegate events - see DWItemFeedViewController
 */
- (id)initWithUser:(DWUser*)theUser 
	   andDelegate:(id)delegate;

@end
