//
//  DWTableViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

/**
 * Data source delegate enables inheriting classes
 * to provide critical information about the table view
 */
@protocol DWTableViewControllerDataSourceDelegate

/**
 * Total number of data rows - i.e. rows excluding loading,pagination
 */
- (NSInteger)numberOfDataRows;

/**
 * Number of rows per page
 */
- (NSInteger)numberOfDataRowsPerPage;

/**
 * Standard height of the data rows
 */
- (CGFloat)heightForDataRows;

/**
 * Load data from the remote server
 */
- (void)loadData;

/**
 * database id for the last data row
 */
- (NSInteger)idForLastDataRow;

/**
 * Lazy load call to load images for the given indexPath
 */
- (void)loadImagesForDataRowAtIndex:(NSIndexPath*)indexPath;

/**
 * Data row at the given index path
 */
- (UITableViewCell*)cellForDataRowAt:(NSIndexPath*)indexPath 
                         inTableView:(UITableView*)tableView;

/**
 * Fired when a data row is selected
 */
- (void)didSelectDataRowAt:(NSIndexPath*)indexPath
               inTableView:(UITableView*)tableView;
@end


/**
 * Encapsulates generic table view controller functionality like
 * pull to refresh and pagination
 */
@interface DWTableViewController : UITableViewController<EGORefreshTableHeaderDelegate,DWTableViewControllerDataSourceDelegate> {
    NSInteger           _lastID;
    NSInteger           _currentPage;
	NSInteger           _tableViewUsage;
	NSInteger           _paginationCellStatus;
	NSInteger           _prePaginationCellCount;
    
    BOOL                _isLoadedOnce;
    BOOL                _isReloading;
    BOOL                _isLoadingPage;
    
    NSString            *_messageCellText;
	
    
	EGORefreshTableHeaderView                       *_refreshHeaderView;
    id<DWTableViewControllerDataSourceDelegate>     _dataSourceDelegate;
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
 * Uses the pagination framework to load the next page of data
 */
- (void)loadNextPage;

/**
 * Cleanup after the data has finished laoding - reset pull to refresh,
 * recheck pagination status
 */
- (void)finishedLoading;

/**
 * Cleanup after a data request has failed with an error.
 */ 
- (void)finishedLoadingWithError;

/**
 * Perform a full refresh of the table view - reset pagination, go to loading state
 * load new data
 */
- (void)hardRefresh;


@end


