//
//  DWItemFeedViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemsManager.h"
#import "DWItemFeedCell.h"

#import "EGORefreshTableHeaderView.h"

@protocol DWItemFeedViewControllerDelegate;
@protocol DWItemFeedCellDelegate;

/**
 * Base class for views that display a feed of items
 */
@interface DWItemFeedViewController : UITableViewController<EGORefreshTableHeaderDelegate,DWItemFeedCellDelegate> {
	
	DWItemsManager	*_itemManager;

	NSInteger		_currentPage;
	NSInteger		_tableViewUsage;
	NSInteger		_paginationCellStatus;
	NSInteger		_prePaginationCellCount;
	
	BOOL			_isReloading;
	BOOL			_isLoadedOnce;
	
	NSDate			*_lastDataRefresh;
	NSString		*_messageCellText;
	
	EGORefreshTableHeaderView				*_refreshHeaderView;
	id <DWItemFeedViewControllerDelegate>	_delegate;
}

/**
 * Manages retreival and creation of items
 */
@property (nonatomic,retain) DWItemsManager *itemManager;

/**
 * Text to be displayed in message mode - see _tableViewUsage
 */
@property (nonatomic,copy) NSString *messageCellText;

/**
 * Date when the content was last refreshed
 */
@property (nonatomic,retain) NSDate *lastRefreshDate;

/**
 * View for pull to refresh added above the table view
 */
@property (nonatomic,retain) EGORefreshTableHeaderView *refreshHeaderView;

/**
 * Init with delegate to receive updates about selection of navigation items
 */
- (id)initWithDelegate:(id)delegate;

/**
 * Disable pagination when there are no more items on the server
 */
- (void)markEndOfPagination;

/** 
 * Reset pagination state to available when the view is being refreshed
 */
- (void)resetPagination;

/**
 * Visible refresh of the table view via a transition through spinner state
 */
- (void)hardRefresh;

/**
 * Stub method overriden by the base classes to load items based on context
 */
- (void)loadItems;

/**
 * Load next page of items using the pagination framework
 */
- (void)loadNextPageOfItems;

/**
 * Add the given new item at the index from the top of the table view
 */
- (void)addNewItem:(DWItem *)item 
		   atIndex:(NSInteger)index;

/**
 * Called by the child classes when the items have been loaded
 */
- (void)finishedLoadingItems;

@end


/**
 * Delegate protocol to receive events when navigation elements are selected
 */
@protocol DWItemFeedViewControllerDelegate

/**
 * Fired when a place is selected from it's name or photo
 */
- (void)placeSelected:(DWPlace*)place;

/**
 * Fired when a user is selected from it's name or photo
 */
- (void)userSelected:(DWUser*)user;

/**
 * Fired when a video or image is selected
 */
- (void)attachmentSelected:(NSString*)url 
		   withIsImageType:(BOOL)isImage;

/** 
 * Fired when a URL in the text is selected
 */
- (void)urlSelected:(NSString*)url;

/** 
 * Fired when the custom tab bar controller is requested for showing the 
 * media picker to change profile picture
 */
- (UIViewController*)requestCustomTabBarController;

@end

