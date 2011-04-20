//
//  DWFollowPlaceView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Custom Follow Place View for PlaceViewControllers Nav Bar
 */
@interface DWFollowPlaceView : UIView {
    UILabel     *followLabel;
    UILabel     *followingCountLabel;
}


/**
 * Update the following count label
 */
- (void)updateFollowingCountLabelWithText:(NSString*)text;

@end



/**
 * Declarations for private methods
 */
@interface DWFollowPlaceView (Private)

- (void)createFollowButton;
- (void)createFollowLabel;
- (void)createFollowingCountLabel;

@end