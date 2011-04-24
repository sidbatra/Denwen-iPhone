//
//  DWSmallProfilePicView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Custom small user image view for userviewcontroller nav bar
 */
@interface DWSmallProfilePicView : UIView {
    UIButton        *profilePicButton;
    UIImageView     *profilePicOverlay;
}


/**
 * Custom init to specify the target for button events
 */
- (id)initWithFrame:(CGRect)frame andTarget:(id)target;

/**
 * Set the background image for the user image button
 */
-(void)setProfilePicButtonBackgroundImage:(UIImage*)image;

@end