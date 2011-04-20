//
//  DWFollowPlaceView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWFollowPlaceViewDelegate;


/**
 * Custom Follow Place View for PlaceViewControllers Nav Bar
 */
@interface DWFollowPlaceView : UIView {
    UILabel     *followLabel;
    UILabel     *followingCountLabel;
    
    BOOL        _isFollowing;
    
    id <DWFollowPlaceViewDelegate>  _delegate;
}

/**
 * Init with delegate to follow/unfollow events
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate;

/**
 * Update the follow button display state and the
 * following count
 */
- (void)updateTitle:(NSString*)title 
        andSubtitle:(NSString*)subtitle 
     andIsFollowing:(BOOL)isFollowing;

@end


/**
 * Declarations for private methods
 */
@interface DWFollowPlaceView (Private)

- (void)createFollowButton;
- (void)createFollowLabel;
- (void)createFollowingCountLabel;

@end


/**
 * Delegate protocol to receive updates events
 * from follow/unfollow 
 */
@protocol DWFollowPlaceViewDelegate 

-(void)didTapFollow;
-(void)didTapUnfollow;

@end


