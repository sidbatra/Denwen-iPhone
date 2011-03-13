//
//  DWItemFeedViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemManager.h"
#import "DWRequestManager.h"

#import "DWItemFeedCell.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"
#import "DWPaginationCell.h"

#import "EGORefreshTableHeaderView.h"

#import "Constants.h"



@protocol DWItemFeedViewControllerDelegate;

@interface DWItemFeedViewController : UITableViewController<EGORefreshTableHeaderDelegate,DWRequestManagerDelegate> {
	
	DWItemManager *_itemManager;
	DWRequestManager *_requestManager;

	NSInteger _currentPage;
	NSInteger _tableViewUsage;
	NSInteger _paginationCellStatus;
	NSInteger _prePaginationCellCount;
	
	BOOL _reloading;
	BOOL _isLoadedOnce;
	
	NSDate *_lastDataRefresh;
	NSString *_messageCellText;
	
	EGORefreshTableHeaderView *_refreshHeaderView;

	id <DWItemFeedViewControllerDelegate> _delegate;

}


@property (copy) NSString *messageCellText;
@property (copy) NSDate *lastDateRefresh;

@property (retain) EGORefreshTableHeaderView *refreshHeaderView;


- (id)initWithDelegate:(id)delegate;

- (void)markEndOfPagination;
- (void)resetPagination;

- (void)hardRefresh;
- (BOOL)loadItems;
- (void)loadNextPageOfItems;
- (void)addNewItem:(DWItem *)item atIndex:(NSInteger)index;
- (void)finishedLoadingItems;

@end

@protocol DWItemFeedViewControllerDelegate
- (void)placeSelected:(NSString*)placeHashedID;
- (void)userSelected:(int)userID;
- (void)attachmentSelected:(NSString*)url withIsImageType:(BOOL)isImage;
- (void)urlSelected:(NSString*)url;
@end

