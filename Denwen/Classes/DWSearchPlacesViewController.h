//
//  DWSearchPlacesViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlaceListViewController.h"

/**
 * Display search results for places
 */
@interface DWSearchPlacesViewController : DWPlaceListViewController {
	UISearchBar *searchBar;
}

/**
 * Init with delegate to receive events about place selection
 */
- (id)initWithDelegate:(id)delegate;

@end
