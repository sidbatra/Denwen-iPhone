//
//  DWPlaceSearchResultCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Forms the background view of a selected place search result cell
 */
@interface DWPlaceSearchResultSelectedView : UIView {
}

@end


/**
 * Forms the background view of a place search results cell
 */
@interface DWPlaceSearchResultView : UIView {
	NSString	*_placeName;
	NSString	*_placeDetails;
	
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
 * Cell for displaying place search results
 */
@interface DWPlaceSearchResultCell : UITableViewCell {
	DWPlaceSearchResultView *_placeSearchResultView;
}

/**
 * Primary view for drawing content
 */
@property (nonatomic,retain) DWPlaceSearchResultView *placeSearchResultView;


/**
 * Reset any variables that may not be refreshed 
 */
- (void)reset;

/**
 * Set the place name
 */
- (void)setPlaceName:(NSString*)placeName;

/**
 * Set the place details
 */ 
- (void)setPlaceDetails:(NSString*)placeDetails;


/**
 * Sets the cell to be rerendered
 */
- (void)redisplay;

@end
