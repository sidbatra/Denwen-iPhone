//
//  DWSegmentedControl.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWSegmentedControlDelegate;

/**
 * Custom segmented control
 */
@interface DWSegmentedControl : UIView {
	NSMutableArray		*_buttons;
	NSInteger			_selectedIndex;
	
	id<DWSegmentedControlDelegate> _delegate;
}

/**
 * Array for UIButton's acting as segments
 */
@property (nonatomic,retain) NSMutableArray *buttons;

/**
 * Init with a frame, names of selected and deselected segments and a delegate
 * to receive events about selected index changes
 */
- (id)initWithFrame:(CGRect)frame withImageNamesForSegments:(NSArray*)images 
  withSelectedIndex:(NSInteger)theSelectedIndex
		andDelegate:(id)theDelegate;

@end

/**
 * Delegate protocol for the custom segmented control 
 */
@protocol DWSegmentedControlDelegate
	/**
	 * Fired when the selected segment is changed
	 */
- (void)selectedSegmentModifiedFrom:(NSInteger)oldSelectedIndex 
								 to:(NSInteger)newSelectedIndex;

@end

