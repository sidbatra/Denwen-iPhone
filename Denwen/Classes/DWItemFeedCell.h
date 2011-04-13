//
//  DWPlaceFeedCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DWGUIManager.h"
#import "InteractiveLabel.h"


/**
 * Forms the background view of a selected item feed cell
 */
@interface DWItemFeedSelectedView : UIView {
}

@end


/**
 * Primary view for DWItemFeedViewCell
 */
@interface DWItemFeedView : UIView {
    //UIImage     *_itemImage;
    UIImageView   *_itemImage;
    NSString    *_itemData;
    
    BOOL        _highlighted;
}

/**
 * Text to be displayed at a place 
 */
@property (nonatomic,copy) NSString* itemData;

/**
 * Place Image
 */
//@property (nonatomic,retain) UIImage* itemImage;
@property (nonatomic,retain) UIImageView* itemImage;


/**
 * Reset any variables that may not be refreshed - eg : _highlight
 */
- (void)reset;

/**
 * Set the view to redraw when visible content has
 * been modified
 */
- (void)redisplay;

@end


/**
 * Cell used in item feed view controller
 */
@interface DWItemFeedCell : UITableViewCell {
    DWItemFeedView *_itemFeedView;
    /*
	id _eventTarget;
	bool _hasAttachment;
	NSInteger _itemID;
	UIButton *placeName;
	UIButton *placeImage;
	UIImageView *userImage;
	InteractiveLabel *dataLabel;
	UILabel *userName;
	UIButton *attachmentImage;
	UIImageView *videoPlayIcon;
	UILabel *timeLabel;
	UIButton *transparentButton;*/
}

/*@property (nonatomic, retain) UIButton *placeName;
@property (nonatomic, retain) UIImageView *userImage;
@property (nonatomic, retain) UIButton *attachmentImage;*/

/**
 * Primary view for drawing content
 */
@property (nonatomic,retain) DWItemFeedView *itemFeedView;


/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the item data
 */
- (void)setItemData:(NSString*)itemData;

/**
 * Set the item image
 */
- (void)setItemImage:(UIImage*)itemImage;

/**
 * Sets the cell to be rerendered
 */
- (void)redisplay;

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;
- (void)updateClassMemberHasAttachment:(BOOL)hasAttachment andItemID:(NSInteger)itemID;
- (void)positionAndCustomizeCellItemsFrom:(NSString*)data userName:(NSString*)fullName andTime:(NSString*)timeAgoInWords;

- (void)disablePlaceButtons;
- (void)disableUserButtons;

- (void)displayNewCellState;
- (void)displayPlayIcon;

- (void)setSmallPreviewPlaceImage:(UIImage*)image;*/

@end

