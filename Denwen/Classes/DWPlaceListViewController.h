//
//  DWPlaceListViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlaceViewController.h"
#import "DWPlacesManager.h"

#import "EGORefreshTableHeaderView.h"


@protocol DWPlaceListViewControllerDelegate;

/**
 * Base class for displaying a list of places
 */
@interface DWPlaceListViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate,EGORefreshTableHeaderDelegate> {
	DWPlacesManager	*_placeManager;
	
	NSString		*_messageCellText;
	NSDate			*_lastRefreshDate;
	
	NSInteger		_tableViewUsage;
	NSInteger		_currentPage; 
	NSInteger		_paginationCellStatus;
	NSInteger		_prePaginationCellCount;
	
	BOOL			_isReloading;
	BOOL			_isLocalSearch;
	BOOL			_isLoadedOnce;

	EGORefreshTableHeaderView				*_refreshHeaderView;
	id <DWPlaceListViewControllerDelegate>	_delegate;
}

/**
 * Manages retreival and creation of DWPlacem mobjects
 */
@property (nonatomic,retain) DWPlacesManager *placeManager;

/**
 * Text to be displayed when tableViewUsuage is message
 */
@property (nonatomic,copy) NSString *messageCellText;

/**
 * Date when the content of the view were last refreshed
 */
@property (nonatomic,retain) NSDate *lastRefreshDate;

/**
 * Pull to refresh view added above the table view
 */
@property (nonatomic,retain) EGORefreshTableHeaderView *refreshHeaderView;

/**
 * Init with 
 * search type (see isLocalSearch)
 * capacity (different types of places needed by the view)
 * delegate to receive events when a place is selected
 */
- (id)initWithSearchType:(BOOL)localSearchFlag
			withCapacity:(NSInteger)capacity 
			 andDelegate:(id)delegate;

/**
 * Reset pagination status - called when the view is fully refreshed
 */
- (void)resetPagination;

/**
 * End of pagination hides the pagination cell when there is no more data
 * on the server
 */
- (void)markEndOfPagination;

/**
 * Force the view to be reloaded completely
 */
- (void)hardRefresh;

/**
 * Stub load places method which is overriden in the child classes
 */
- (void)loadPlaces;

/**
 * Load next page of data in the pagination framework
 */
- (void)loadNextPageOfPlaces;

/**
 * Inserts a new place onto the top of the table view
 */
- (void)addNewPlace:(DWPlace*)place;

/**
 * Called from the child classes when the places have been loaded
 */
- (void)finishedLoadingPlaces;

/**
 * Fired when the view is selected in a segmented controller setup
 */
- (void)viewIsSelected;

/**
 * Fired when the view is deselected in a segmented controller setup
 */
- (void)viewIsDeselected;

/**
 * Refresh search places UI
 */
- (void)refreshFilteredPlacesUI;

@end


/**
 * Delegate protocol to receive updates from all children of place list view
 */
@protocol DWPlaceListViewControllerDelegate

/**
 * Fired when a place cell is selected
 */
- (void)placeSelected:(DWPlace*)place;

@end

