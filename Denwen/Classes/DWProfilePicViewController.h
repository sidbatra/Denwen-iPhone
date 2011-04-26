//
//  DWProfilePicViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWUser.h"
#import "DWUserProfileTitleView.h"

/**
 * Controller for viewing/changing user picture 
 */
@interface DWProfilePicViewController : UIViewController<UIScrollViewDelegate> {
    DWUser                      *_user;
    DWUserProfileTitleView      *_userProfileTitleView;
    
    NSInteger           _key;
    id                  _delegate;
}

/**
 * User object whose view is being displayed
 */
@property (nonatomic,retain) DWUser *user;

/**
 * Subview for displaying user name and spinner while processing
 */
@property (nonatomic,retain) DWUserProfileTitleView *userProfileTitleView;

/**
 * Initialize with images url and current
 */
- (id)initWithUser:(DWUser*)user andDelegate:(id)delegate;

@end
