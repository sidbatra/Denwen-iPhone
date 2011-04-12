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

@end

/**
 * Delegate protocol for the custom tab bar
 */
@protocol DWTabBarDelegate

@end

