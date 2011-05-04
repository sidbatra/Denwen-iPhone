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
    BOOL                            _hasAttachment;
    BOOL                            _hasQuote;
    
    CGRect                          _userRect;
    CGRect                          _dataRect;
    CGRect                          _placeRect;
    CGRect                          _quoteRect;
	
	NSString						*_userName;
    NSString                        *_itemData;
    NSString                        *_placeData;
}

/**
 * Name of the person touching the post
 */
@property (nonatomic,copy) NSString* userName;

/**
 * Data associated with the item touched
 */
@property (nonatomic,copy) NSString* itemData;

/**
 * Name of the place where the touched item was posted
 */
@property (nonatomic,copy) NSString* placeData;

/**
 * Indicates presence of attachment
 */
@property (nonatomic,assign) BOOL hasAttachment;

/**
 * Flags whether the quote to end a sentence is needed or not
 */
@property (nonatomic,readonly) BOOL hasQuote;

/**
 * CGRect's for all the individual text elements
 */
@property (nonatomic,readonly) CGRect userRect;
@property (nonatomic,readonly) CGRect dataRect;
@property (nonatomic,readonly) CGRect placeRect;
@property (nonatomic,readonly) CGRect quoteRect;


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
 * Takes the place name and item data to generate display string
 */
- (void)setPlaceName:(NSString*)placeName 
         andItemData:(NSString*)theItemData;

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
