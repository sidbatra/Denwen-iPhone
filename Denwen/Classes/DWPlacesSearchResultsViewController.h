//
//  DWPlacesSearchResultsViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlacesManager.h"

@protocol DWPlacesSearchResultsViewControllerDelegate;

/**
 * Displays search results for places in an SMS style UI
 */
@interface DWPlacesSearchResultsViewController : UITableViewController {
	DWPlacesManager		*_placesManager;
	NSString			*_searchText;
	NSInteger			_tableViewUsage;
	BOOL				_newPlaceMode;
	
	id <DWPlacesSearchResultsViewControllerDelegate>	_delegate;
}

/**
 * Search text to filter places
 */
@property (nonatomic,copy) NSString *searchText;

/**
 * Reference to the DWPlacesCache placesManager
 */
@property (nonatomic,retain) DWPlacesManager *placesManager;

/**
 * Delegate for receiving events on place selection
 */
@property (nonatomic, assign) id<DWPlacesSearchResultsViewControllerDelegate> delegate;


/**
 * Filters the available places by the given search queries and displays them
 * If the search text is an empty string the tableView hides itself
 */
- (void)filterPlacesBySearchText;


@end

/**
 * Delegate protocol to receive updates about place search result
 * selection
 */
@protocol DWPlacesSearchResultsViewControllerDelegate

/**
 * Fired when user selects an existing place
 */
- (void)placeSelected:(DWPlace*)place;

/**
 * Fired when user selects the create new place cell
 */
- (void)newPlaceSelected;

/**
 * Queries the parent class to check for new place mode
 */
- (BOOL)isNewPlaceMode;

/**
 * Queries the parent class to check is a place has been 
 * selected
 */
- (BOOL)isPlaceSelected;

@end