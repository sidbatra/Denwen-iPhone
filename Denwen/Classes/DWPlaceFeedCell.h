//
//  DWPlaceFeedCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

/**
 * Forms the background view of a selected place feed cell
 */
@interface DWPlaceFeedSelectedView : UIView {
}

@end


/**
 * Primary view for DWPlaceFeedViewCell
 */
@interface DWPlaceFeedView : UIView {
	NSString		*_placeName;
	NSString		*_placeData;
	NSString		*_placeDetails;
	UIImage			*_placeImage;
	
	CALayer			*_placeImageLayer;
	CALayer			*_placeNameLayer;
	
	BOOL			_highlighted;
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
 * Place Image
 */
@property (nonatomic,retain) UIImage* placeImage;

@property (nonatomic,retain) CALayer* placeImageLayer;

@property (nonatomic,retain) CALayer* placeNameLayer;

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
 * Cell used in place list view controller
 */
@interface DWPlaceFeedCell : UITableViewCell {
	DWPlaceFeedView *_placeFeedView;
     UIImageView	*_placeImageView;
}

/**
 * Primary view for drawing content
 */
@property (nonatomic,retain) DWPlaceFeedView *placeFeedView;

@property (nonatomic,retain) UIImageView* placeImageView;

/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the place name
 */
- (void)setPlaceName:(NSString*)placeName;

/**
 * Set the 
 */
- (void)setPlaceData:(NSString*)placeData;

/**
 * Set the place details
 */ 
- (void)setPlaceDetails:(NSString*)placeDetails;

/**
 * Set the place image
 */
- (void)setPlaceImage:(UIImage*)placeImage;

/**
 * Sets the cell to be rerendered
 */
- (void)redisplay;

@end
