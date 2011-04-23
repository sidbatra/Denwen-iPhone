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
    UIActivityIndicatorView *spinner;
}

/**
 * Display followed state
 */
- (void)showFollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount;

/**
 * Display followed state
 */
- (void)showUnfollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount;

/**
 * Display processing state
 */
- (void)showProcessingState;

@end


/**
 * Declarations for private methods
 */
@interface DWPlaceTitleView (Private)

- (void)createSpinner;

@end