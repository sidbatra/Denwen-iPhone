//
//  DWUserProfileTitleView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTitleView.h"


/**
 * Custom user profile title view for profilepicview controller nav bar
 */
@interface DWUserProfileTitleView : DWTitleView {
    
}

/**
 * Display users name 
 */
- (void)showUserStateFor:(NSString*)userName andIsCurrentUser:(BOOL)isCurrentUser;

/**
 * Display processing state
 */
- (void)showProcessingState;

/**
 * Display the normal state
 */
- (void)showNormalState;


@end
