//
//  DWPlaceTitleView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTitleView.h"


/**
 * Custom place title view for placeviewcontroller nav bar
 */
@interface DWPlaceTitleView : DWTitleView {

}

/**
 * Display followed state
 */
- (void)showFollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount;

/**
 * Display unfollowed state
 */
- (void)showUnfollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount;

/**
 * Display processing state
 */
- (void)showProcessingState;

@end