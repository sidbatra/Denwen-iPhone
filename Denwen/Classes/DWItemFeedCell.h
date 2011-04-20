//
//  DWPlaceFeedCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class DWItemFeedCell;
@protocol DWItemFeedCellDelegate;

/**
 * Custom layer for display elements that are drawn
 * via core graphics, mostly used for text
 */
@interface DWItemFeedCellDrawingLayer : CALayer {
	DWItemFeedCell	*itemCell;
	BOOL			_disableAnimation;
}

/**
 * Non retained reference to the item feed cell
 */
@property (nonatomic,assign) DWItemFeedCell *itemCell;

/**
 * Disable content animations on item feed
 */
@property (nonatomic,assign) BOOL disableAnimation;

@end


/**
 * Cell used in item feed view controller
 */
@interface DWItemFeedCell : UITableViewCell {
	
	CALayer							*itemImageLayer;
	CALayer							*touchIconImageLayer;
	CALayer							*touchedImageLayer;
	CALayer							*playImageLayer;
	CALayer							*shareImageLayer;

	DWItemFeedCellDrawingLayer		*drawingLayer;

	
	BOOL							_highlighted;
	BOOL							_placeButtonPressed;
	BOOL							_userButtonPressed;
	
	NSInteger						_itemID;
	NSInteger						_itemTouchesCount;
	NSInteger						_attachmentType;
	
	NSString						*_itemData;
	NSString						*_itemPlaceName;
	NSString						*_itemUserName;
	NSString						*_itemCreatedAt;
	NSString						*_itemDetails;
	
	NSDate							*_highlightedAt;

	CGRect							_userNameRect;
	CGRect							_atRect;
	CGRect							_placeNameRect;
	CGRect							_dataRect;
	CGRect							_detailsRect;

	
	UIButton						*placeButton;
	UIButton						*userButton;
	UIButton						*shareButton;
	
	id<DWItemFeedCellDelegate>		_delegate;
}


@property (nonatomic,assign) NSInteger itemID;
@property (nonatomic,assign) NSInteger attachmentType;

@property (nonatomic,readonly) BOOL placeButtonPressed;
@property (nonatomic,readonly) BOOL userButtonPressed;

@property (nonatomic,copy) NSString* itemData;
@property (nonatomic,copy) NSString* itemPlaceName;
@property (nonatomic,copy) NSString* itemUserName;
@property (nonatomic,copy) NSString* itemCreatedAt;
@property (nonatomic,copy) NSString* itemDetails;

@property (nonatomic,retain) NSDate* highlightedAt;

@property (nonatomic,readonly) CGRect userNameRect;
@property (nonatomic,readonly) CGRect atRect;
@property (nonatomic,readonly) CGRect placeNameRect;
@property (nonatomic,readonly) CGRect dataRect;
@property (nonatomic,readonly) CGRect detailsRect;


@property (nonatomic,assign) id<DWItemFeedCellDelegate> delegate;


/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the item image
 */
- (void)setItemImage:(UIImage*)itemImage;

/**
 * Set item details - touchesCount and createdAtString
 */
- (void)setDetails:(NSInteger)touchesCount 
	  andCreatedAt:(NSString*)createdAt;

/**
 * Sets the cell to be rerendered
 */
- (void)redisplay;

@end


/**
 * Declarations for select private methods
 */
@interface DWItemFeedCell(Private)
- (void)highlightCell;
- (void)fadeCell;
- (void)touchCell;
- (void)finishTouchCell;
@end


/**
 * Delegate protocol to send events about cell interactions
 */
@protocol DWItemFeedCellDelegate
- (void)cellTouched:(NSInteger)itemID;
- (void)placeSelectedForItemID:(NSInteger)itemID;
- (void)userSelectedForItemID:(NSInteger)itemID;
- (void)shareSelectedForItemID:(NSInteger)itemID;
@end
