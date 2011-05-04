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
 * Selected segment index
 */
@property (nonatomic,readonly) NSInteger selectedIndex;

/**
 * Init with a frame, delegate to receive index change events
 * and an array of dictionaries to provide width, selection
 * status, state images and other properties of each segment
 */
- (id)initWithFrame:(CGRect)frame 
   withSegmentsInfo:(NSArray*)segmentsInfo
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

