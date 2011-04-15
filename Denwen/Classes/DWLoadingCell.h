//
//  DWLoadingCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Displaying a loading state
 */
@interface DWLoadingCell : UITableViewCell {
	UIActivityIndicatorView		*spinner;
	UILabel						*messageLabel;
	
	BOOL						_isShortMode;
}

/**
 * Loading spinner
 */
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

/**
 * Adjusts the cell to accomodate a shorter container
 */
- (void)shorterCellMode;

@end

/**
 * Declarations for private methods
 */
@interface DWLoadingCell (Private)

- (void)createBackground;
- (void)createSpinner;
- (void)createMessageLabel;

@end
