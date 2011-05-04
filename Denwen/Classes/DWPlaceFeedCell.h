//
//  DWPlaceFeedCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class DWPlaceFeedCell;

/**
 * Custom layer for display elements that are drawn
 * via core graphics, mostly used for text
 */
@interface DWPlaceFeedCellDrawingLayer : CALayer {
	DWPlaceFeedCell *placeCell;
}

/**
 * Non retained reference to the place feed cell
 */
@property (nonatomic,assign) DWPlaceFeedCell *placeCell;

@end


/**
 * Represents a place in a list
 */
@interface DWPlaceFeedCell : UITableViewCell {	
	
	CALayer							*placeImageLayer;
	DWPlaceFeedCellDrawingLayer		*drawingLayer;
	
	BOOL							_highlighted;
    BOOL                            _hasAttachment;
	
	NSString						*_placeName;
	NSString						*_placeData;
	NSString						*_placeDetails;
}

/**
 * Place name
 */
@property (nonatomic,copy) NSString* placeName;

/**
 * Text to be displayed at a place 
 */
@property (nonatomic,copy) NSString* placeData;

/**
 * The address for the place
 */
@property (nonatomic,copy) NSString* placeDetails;

/**
 * Flag for whether the last item at a place had an attachment
 * or not
 */
@property (nonatomic,assign) BOOL hasAttachment;

/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the place image via the placeImageLayer
 */
- (void)setPlaceImage:(UIImage*)placeImage;

/**
 * Mark layers for redisplay
 */
- (void)redisplay;

@end

/**
 * Declarations for select private methods
 */
@interface DWPlaceFeedCell(Private)
- (void)highlightCell;
- (void)fadeCell;
@end
