//
//  DWPlaceListViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlaceViewController.h"
#import "DWPlaceManager.h"
#import "MBProgressHUD.h"
#import "DWPlaceFeedCell.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"
#import "Constants.h"

#import "EGORefreshTableHeaderView.h"



@protocol DWPlaceListViewControllerDelegate;



@interface DWPlaceListViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate,EGORefreshTableHeaderDelegate> {
	DWPlaceManager *_placeManager;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	id <DWPlaceListViewControllerDelegate> _delegate;
	
	NSDate *_lastDataRefresh;
	NSString *_messageCellText;
	
	NSInteger _tableViewUsage;
	NSInteger _currentPage; 
	NSInteger _paginationCellStatus;
	NSInteger _prePaginationCellCount;
	
	BOOL _reloading;
	BOOL _isLocalSearch;
	BOOL _isLoadedOnce;
}


@property (copy) NSString *messageCellText;
@property (copy) NSDate *lastDateRefresh;

@property (retain) EGORefreshTableHeaderView *refreshHeaderView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil searchType:(BOOL)isLocalSearch 
		  withCapacity:(NSInteger)capacity andDelegate:(id)delegate;

- (void)resetPagination;
- (void)markEndOfPagination;

- (void)hardRefresh;
- (void)loadPlaces;
- (void)loadNextPageOfPlaces;
- (void)addNewPlace:(DWPlace *)place;
- (void)finishedLoadingPlaces;

- (void)viewIsSelected;
- (void)viewIsDeselected;
- (void)refreshFilteredPlacesUI;

@end

@protocol DWPlaceListViewControllerDelegate
- (void)placeSelected:(DWPlace*)place;
@end

