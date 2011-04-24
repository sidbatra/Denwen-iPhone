//
//  DWTableViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

/**
 * Encapsulates generic table view controller functionality like
 * pull to refresh and pagination
 */
@interface DWTableViewController : UITableViewController<EGORefreshTableHeaderDelegate> {
    NSInteger           _currentPage;
	NSInteger           _tableViewUsage;
	NSInteger           _paginationCellStatus;
	NSInteger           _prePaginationCellCount;
    NSInteger           _rowsPerPage;
    
    BOOL                _isReloading;
    
    NSString            *_messageCellText;
	
    
	EGORefreshTableHeaderView				*_refreshHeaderView;
}

/**
 * Text to be displayed in message mode - see _tableViewUsage
 */
@property (nonatomic,copy) NSString *messageCellText;

/**
 * View for pull to refresh added above the table view
 */
@property (nonatomic,retain) EGORefreshTableHeaderView *refreshHeaderView;


/**
 * Reset pagination status back to active and current page back tto its
 * initital value
 */
- (void)resetPagination;

/**
 * End pagination and set a flag to hide the pagination cell
 */
- (void)markEndOfPagination;

/**
 * Load the data to populate the cells of the table view. Overriden
 * in the child class
 */
- (void)loadData;

/**
 * Uses the pagination framework to load the next page of data
 */
- (void)loadNextPage;

/**
 * Cleanup after the data has finished laoding - reset pull to refresh,
 * recheck pagination status
 */
- (void)finishedLoading;

/**
 * Start lazy loaded images for the currently visible cells
 */
- (void)loadImagesForOnscreenRows;

/**
 * Overriden in the child class to return the total 
 * number of rows in the table
 */
- (NSInteger)totalRows;

/**
 * Overriden in the child class to return the height of the
 * primary data cell
 */
- (NSInteger)dataCellHeight;

@end


/**
 * Declarations for select private methods
 */
@interface DWTableViewController(Private)
- (void)resetPagination;
@end
