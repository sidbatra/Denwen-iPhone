//
//  DWTitleView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWTitleViewDelegate;


/**
 * Generic title view for the navigation bar
 */
@interface DWTitleView : UIView {
    UILabel     *titleLabel;
    UILabel     *subtitleLabel;
    UILabel     *standaloneTitleLabel;
    UIButton    *underlayButton;
    
    id <DWTitleViewDelegate>  _delegate;
}

/**
 * Init with appropriate title view mode and delegate to to 
 * fire events when the titleView button is tapped
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate andMode:(NSInteger)titleViewMode;


/** 
 * Title view button pressed
 */
- (void)titleViewButtonPressed;

@end


/**
 * Declarations for private methods
 */
@interface DWTitleView (Private)

- (void)createUnderlayButton;
- (void)createTitleLabel;
- (void)createSubtitleLabel;
- (void)createStandaloneTitleLabel;

@end


/**
 * Delegate protocol to receive updates when
 * the titleview is tapped
 */
@protocol DWTitleViewDelegate 

-(void)didTapTitleView;

@end


