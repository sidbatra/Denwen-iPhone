//
//  DWProfilePicViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWUser.h"
#import "DWUserProfileTitleView.h"
#import "DWItemFeedViewController.h"
#import "DWProfilePicManager.h"

/**
 * Controller for viewing/changing user picture 
 */
@interface DWProfilePicViewController : UIViewController<UIScrollViewDelegate,DWProfilePicManagerDelegate> {
    
    DWUser                      *_user;
    DWUserProfileTitleView      *_userProfileTitleView;
    DWProfilePicManager         *_profilePicManager;
    
    NSInteger                   _key;
    
    id <DWItemFeedViewControllerDelegate>       _delegate;
}

/**
 * Initialize with images url and current
 */
- (id)initWithUser:(DWUser*)user andDelegate:(id)delegate;


/**
 * User object whose view is being displayed
 */
@property (nonatomic,retain) DWUser *user;

/**
 * Subview for displaying user name and spinner while processing
 */
@property (nonatomic,retain) DWUserProfileTitleView *userProfileTitleView;

/**
 * Profile pic manager for handling all the DWMediaPicker Events
 */
@property (nonatomic,retain) DWProfilePicManager *profilePicManager;


@end
