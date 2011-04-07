//
//  DWPlacesSearchResultsViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlacesManager.h"

/**
 * Displays search results for places in an SMS style UI
 */
@interface DWPlacesSearchResultsViewController : UITableViewController {
	DWPlacesManager		*_placesManager;
	NSString			*_searchText;
	NSInteger			_tableViewUsage;
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
 * Filters the available places by the given search queries and displays them
 * If the search text is an empty string the tableView hides itself
 */
- (void)filterPlacesBySearchText;


@end
