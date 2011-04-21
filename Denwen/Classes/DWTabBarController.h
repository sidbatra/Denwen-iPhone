//
//  DWTabBarController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@class DWTabBar;
@protocol DWTabBarControllerDelegate;

/**
 * Custom tab bar controller
 */
@interface DWTabBarController : UIViewController {
	DWTabBar			*_tabBar;
	NSArray				*_subControllers;
    UIImageView         *_shadowView;
	
	id<DWTabBarControllerDelegate> _delegate;
}

/**
 * Tab bar object for managing for the buttons and their states
 */
@property (nonatomic,retain) DWTabBar *tabBar;

/**
 * Image view with a shadow just above the tab bar
 */
@property (nonatomic,retain) UIImageView *shadowView;

/**
 * Controllers added to the tab bar 
 */
@property (nonatomic,retain) NSArray *subControllers;

/**
 * Init with delegate to receive events about tab bar clicks,
 * frame for drawing the tab bar
 * and tab bar info for creating the buttons in the tab bar
 */
- (id)initWithDelegate:(id)theDelegate 
	   withTabBarFrame:(CGRect)tabBarFrame
		 andTabBarInfo:(NSArray*)tabBarInfo;

@end

/**
 * Delegate protocol to send events about index changes
 */
@protocol DWTabBarControllerDelegate

/**
 * Fired when the selected tab changes
 */
- (void)selectedTabModifiedFrom:(NSInteger)oldSelectedIndex 
							 to:(NSInteger)newSelectedIndex;
@end

/**
 * Declarations for select private methods
 */
@interface DWTabBarController(Private)

/**
 * Adds the view for the tabBarControllers
 */
- (void)addViewAtIndex:(NSInteger)index;

/**
 * Returns the subController corresponding to the
 * currently selected tab bar button
 */
- (UIViewController*)getSelectedController;
@end
