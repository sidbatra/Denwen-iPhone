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
    UIImageView                 *backgroundImageView;
	
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

/**
 * Revamp the cell to display a classic short height grey on black a
 *a pple loading cell
 */
- (void)defaultAppleMode;

@end

/**
 * Declarations for private methods
 */
@interface DWLoadingCell (Private)

- (void)createBackground;
- (void)createSpinner;
- (void)createMessageLabel;

@end
