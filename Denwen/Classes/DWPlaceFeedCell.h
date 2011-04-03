//
//  DWPlaceFeedCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Primary view for DWPlaceFeedViewCell
 */
@interface DWPlaceFeedView : UIView {
	NSString	*_placeName;
	NSString	*_placeDetails;
	UIImage		*_placeImage;
	
	BOOL		_highlighted;
}

/**
 * Place name
 */
@property (nonatomic,copy) NSString* placeName;

/**
 * The address for the place
 */
@property (nonatomic,copy) NSString* placeDetails;

/**
 * Place Image
 */
@property (nonatomic,retain) UIImage* placeImage;

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
}

/**
 * Primary view for drawing content
 */
@property (nonatomic,retain) DWPlaceFeedView *placeFeedView;

/**
 * Set the place name
 */
- (void)setPlaceName:(NSString*)placeName;

/**
 * Set the place details
 */ 
- (void)setPlaceDetails:(NSString*)placeDetails;

/**
 * Set the place image
 */
- (void)setPlaceImage:(UIImage*)placeImage;

@end
