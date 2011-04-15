//
//  DWPlaceFeedCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class DWItemFeedCell;

/**
 * Custom layer for display elements that are drawn
 * via core graphics, mostly used for text
 */
@interface DWItemFeedCellDrawingLayer : CALayer {
	DWItemFeedCell *itemCell;
}

/**
 * Non retained reference to the item feed cell
 */
@property (nonatomic,assign) DWItemFeedCell *itemCell;

@end


/**
 * Cell used in item feed view controller
 */
@interface DWItemFeedCell : UITableViewCell {
	
	CALayer							*itemImageLayer;
	DWItemFeedCellDrawingLayer		*drawingLayer;

	
	BOOL							_highlighted;
	
	NSString						*_itemData;
}

/**
 * Text to be displayed on top of the item
 */
@property (nonatomic,copy) NSString* itemData;

/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the item image
 */
- (void)setItemImage:(UIImage*)itemImage;

/**
 * Sets the cell to be rerendered
 */
- (void)redisplay;

@end

