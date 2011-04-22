//
//  DWTabBar.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWTabBarDelegate;

/**
 * Custom tab bar
 */
@interface DWTabBar : UIView {
	NSMutableArray	*_buttons;
	NSInteger		_selectedIndex;
	
	id<DWTabBarDelegate> _delegate;
}

/**
 * Array of tab bar buttons
 */
@property (nonatomic,retain) NSMutableArray *buttons;

/**
 * Currently selected tab bar button
 */
@property (nonatomic,readonly) NSInteger selectedIndex;

/**
 * Init with frame for the tab bar, tab bar info for each tab
 * and delegate to receive events on tab bar clicks
 */
- (id)initWithFrame:(CGRect)frame 
		   withInfo:(NSArray*)tabsInfo
		andDelegate:(id)theDelegate;

@end

/**
 * Delegate protocol for the custom tab bar
 */
@protocol DWTabBarDelegate

/**
 * Fired when current tab changes.
 * navReset - Pops the selected nav to root view controller
 */
- (void)selectedTabWithSpecialTab:(BOOL)isSpecial
					 modifiedFrom:(NSInteger)oldSelectedIndex 
							   to:(NSInteger)newSelectedIndex
                     withNavReset:(BOOL)navReset;
@end