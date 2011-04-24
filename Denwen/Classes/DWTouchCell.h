//
//  DWTouchCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class DWTouchCell;

/**
 * Custom layer for display elements that are drawn
 * via core graphics, mostly used for text
 */
@interface DWTouchCellDrawingLayer : CALayer {
	DWTouchCell *touchCell;
}

/**
 * Non retained reference to the touch cell
 */
@property (nonatomic,assign) DWTouchCell *touchCell;

@end


/**
 * Represents a touch in a cell
 */
@interface DWTouchCell : UITableViewCell {	
	
    CALayer							*attachmentImageLayer;
	CALayer							*userImageLayer;
	DWTouchCellDrawingLayer         *drawingLayer;
	
	BOOL							_highlighted;
	
	NSString						*_itemData;
}

/**
 * Item data
 */
@property (nonatomic,copy) NSString* itemData;


/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the attachment image via the attachmentImageLayer
 */
- (void)setAttachmentImage:(UIImage*)attachmentImage;

/**
 * Set the user image via the userImageLayer
 */
- (void)setUserImage:(UIImage*)userImage;

/**
 * Mark layers for redisplay
 */
- (void)redisplay;

@end


/**
 * Declarations for select private methods
 */
@interface DWTouchCell(Private)
- (void)highlightCell;
- (void)fadeCell;
@end
