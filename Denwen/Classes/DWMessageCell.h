//
//  DWMessageCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Display a custom message
 */
@interface DWMessageCell : UITableViewCell {
	UILabel		*messageLabel;
	
	BOOL		_isShortMode;
}

/**
 * Label used to display the message
 */
@property (nonatomic, retain) UILabel *messageLabel;

/**
 * Adjusts the cell to accomodate a shorter container
 */
- (void)shorterCellMode;

@end
