//
//  DWPlaceListViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceListViewController.h"
#import "DWConstants.h"

//Cells
#import "DWPlaceFeedCell.h"
#import "DWPaginationCell.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"

static float	 const kSeparatorRedValue			= 0.921;
static float	 const kSeparatorGreenValue			= 0.921;
static float	 const kSeparatorBlueValue			= 0.921;
static float	 const kSeparatorAlphaValue			= 1.0;
static NSInteger const kSearchBarOffset				= 44;
static NSInteger const kDefaultPlacesRow			= 0;
static NSInteger const kDefaultSections				= 1;
static NSInteger const kPlaceFeedCellHeight			= 56;
static NSInteger const kSearchPlaceActiveCellHeight	= 3000;
static NSString* const kPlaceFeedCellIdentifier		= @"PlaceFeedCell";
static NSInteger const kMessageCellIndex			= 1;
static NSInteger const kSpinnerCellIndex			= 1;
static NSInteger const kSearchActiveAlpha			= 0.8;
static NSInteger const kSearchInActiveAlpha			= 1.0;
static NSInteger const kPlacesPerPage				= 20;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceListViewController

@synthesize placeManager			= _placeManager;
@synthesize messageCellText			= _messageCellText;
@synthesize lastRefreshDate			= _lastRefreshDate;
@synthesize refreshHeaderView		= _refreshHeaderView;


//----------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
		   searchType:(BOOL)localSearchFlag
		 withCapacity:(NSInteger)capacity 
		  andDelegate:(id)delegate {
		
	self = [super initWithNibName:nibNameOrNil 
						   bundle:nibBundleOrNil];
	
	if (self) {
		
		_delegate = delegate;
		
		self.placeManager		= [[[DWPlaceManager alloc] initWithCapacity:capacity] autorelease];
		_tableViewUsage			= kTableViewAsSpinner;
		_isLocalSearch			= localSearchFlag;
		_isReloading			= NO;
		_isLoadedOnce			= NO;
		
		[self resetPagination];
				
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallPlaceImageLoaded:) 
													 name:kNImgSmallPlaceLoaded
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	self.view.hidden	= YES;

	CGRect frame		= self.view.frame;
	frame.origin.y		= 0; 
	self.view.frame		= frame;
	
	
	[self.tableView setSeparatorColor:[UIColor colorWithRed:kSeparatorRedValue 
													  green:kSeparatorGreenValue
													   blue:kSeparatorBlueValue
													  alpha:kSeparatorAlphaValue]];

	/**
	 * Tuck the search bar above the table view
	 */
	[self.tableView setContentOffset:CGPointMake(0,kSearchBarOffset) animated:NO];
	
	
	self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																						  0.0f - self.tableView.bounds.size.height,
																						  self.view.frame.size.width,
																						  self.tableView.bounds.size.height)] autorelease];
	self.refreshHeaderView.delegate = self;
	[self.tableView addSubview:self.refreshHeaderView];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
	self.refreshHeaderView = nil;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	self.placeManager		= nil;
	self.messageCellText	= nil;
	self.lastRefreshDate	= nil;
	self.refreshHeaderView	= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewIsSelected {
	self.view.hidden = NO;

	if(!_isLoadedOnce) {
		[self loadPlaces];
		_isLoadedOnce = YES;
	}
}

//----------------------------------------------------------------------------------------------------
- (void)viewIsDeselected {
	[self.searchDisplayController.searchBar resignFirstResponder];
	self.view.hidden = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)resetPagination {
	_currentPage = kPagInitialPage;
	_paginationCellStatus = 1;
}

//----------------------------------------------------------------------------------------------------
- (void)markEndOfPagination {
	_paginationCellStatus = 0;
}

//----------------------------------------------------------------------------------------------------
- (void)addNewPlace:(DWPlace*)place {
	
	if(_tableViewUsage != kTableViewAsData) {
		_tableViewUsage = kTableViewAsData;
		[self.tableView reloadData];
	}
	
	[_placeManager addPlace:place
					  atRow:kDefaultPlacesRow
				  andColumn:0];
	
	NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:kDefaultPlacesRow
													 inSection:0];
	NSArray *indexPaths			= [NSArray arrayWithObjects:placeIndexPath,nil];
	
	[self.tableView insertRowsAtIndexPaths:indexPaths
						  withRowAnimation:UITableViewRowAnimationRight];
}

//----------------------------------------------------------------------------------------------------
- (void)hardRefresh {
	_isReloading	= YES;
	_tableViewUsage = kTableViewAsSpinner;
	
	[self.tableView reloadData];
	[self			loadPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)loadPlaces {
	self.lastRefreshDate = [NSDate dateWithTimeIntervalSinceNow:0];
}

//----------------------------------------------------------------------------------------------------
- (void)loadNextPageOfPlaces {
	_prePaginationCellCount = [_placeManager totalPlacesAtRow:kDefaultPlacesRow];
	_currentPage++;
	
	[self loadPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)finishedLoadingPlaces {
	[self.refreshHeaderView refreshLastUpdatedDate];
	
	if([_placeManager totalPlacesAtRow:kDefaultPlacesRow] < kPlacesPerPage || 
	   ([_placeManager totalPlacesAtRow:kDefaultPlacesRow] - _prePaginationCellCount < kPlacesPerPage &&
			!_isReloading)) { 
		
		/**
		 * Mark end of pagination is no new items are found
		 */
		_prePaginationCellCount = 0;
		[self markEndOfPagination];
	}

	if(_isReloading) {
		[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
		_isReloading = NO;
	}
}


//----------------------------------------------------------------------------------------------------
- (void)searchPlaces:(NSString*)query {
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private

//----------------------------------------------------------------------------------------------------
- (void)refreshFilteredPlacesUI {
	[self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
	[self.searchDisplayController.searchResultsTableView setRowHeight:kPlaceFeedCellHeight];
	self.searchDisplayController.searchResultsTableView.alpha = kSearchInActiveAlpha;
	self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) { 
		[subview removeFromSuperview]; 
	}
	
	if(!_isLocalSearch)
		[self.searchDisplayController.searchResultsTableView reloadData];	
}


//----------------------------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows {
	NSArray *visiblePaths = self.searchDisplayController.isActive ? 
	[self.searchDisplayController.searchResultsTableView indexPathsForVisibleRows] :
	[self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) { 
		DWPlace *place = self.searchDisplayController.isActive ? 
		[_placeManager getFilteredPlace:indexPath.row] :
		[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		[place startSmallPreviewDownload];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

- (void)smallPlaceImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData || !_isLoadedOnce)
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	

	NSArray *visiblePaths = self.searchDisplayController.isActive ? 
	[self.searchDisplayController.searchResultsTableView indexPathsForVisibleRows] :
	[self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWPlace *place = self.searchDisplayController.isActive ? 
		[_placeManager getFilteredPlace:indexPath.row] :
		[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		if(place.databaseID == resourceID) {
			DWPlaceFeedCell *cell = nil;
			
			if(self.searchDisplayController.isActive)
				cell = (DWPlaceFeedCell*)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
			else	
				cell = (DWPlaceFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];

			[cell setPlaceImage:[info objectForKey:kKeyImage]];
		}
	}	
	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate 

//----------------------------------------------------------------------------------------------------
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	if(!self.searchDisplayController.isActive) {
		[self resetPagination];
		
		_isReloading = YES;
		[self loadPlaces];
	}
}

//----------------------------------------------------------------------------------------------------
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _isReloading; 
}

//----------------------------------------------------------------------------------------------------
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return self.lastRefreshDate;
}



#pragma mark -
#pragma mark UITableViewDataSource


//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kDefaultSections;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	

	NSInteger rows = 0;
	
	if(_tableViewUsage == kTableViewAsData)
		rows = self.searchDisplayController.isActive ? 
					[_placeManager totalFilteredPlaces] : 
					[_placeManager totalPlacesAtRow:section] + _paginationCellStatus;
	else
		rows = kTVLoadingCellCount;
			
	return rows;
}


//----------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CGFloat height = 0;
	
	if(_tableViewUsage == kTableViewAsData && 
			(self.searchDisplayController.isActive || 
				indexPath.row < [_placeManager totalPlacesAtRow:indexPath.section]) )
		
		height = kPlaceFeedCellHeight;
	
	else if(_tableViewUsage == kTableViewAsData && 
			indexPath.row == [_placeManager totalPlacesAtRow:indexPath.section])
		
		height = kPlaceFeedCellHeight;
	else
		height = kTVLoadingCellHeight;
	
	return height;
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
		
	if(_tableViewUsage == kTableViewAsData && 
			(self.searchDisplayController.isActive || 
				indexPath.row < [_placeManager totalPlacesAtRow:indexPath.section]) ) {
				
		DWPlace *place = self.searchDisplayController.isActive && 
							tableView == self.searchDisplayController.searchResultsTableView ? 
								[_placeManager getFilteredPlace:indexPath.row] :
								[_placeManager getPlaceAtRow:indexPath.section
												   andColumn:indexPath.row];
		
		
		DWPlaceFeedCell *cell = (DWPlaceFeedCell*)[tableView dequeueReusableCellWithIdentifier:kPlaceFeedCellIdentifier];
				
		if (!cell) 
			cell = [[[DWPlaceFeedCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:kPlaceFeedCellIdentifier] autorelease];
		
		
		[cell setPlaceName:place.name];
		[cell setPlaceDetails:[place displayAddress]];
		
		if (!tableView.dragging && !tableView.decelerating)
			[place startSmallPreviewDownload];
		
		if (place.smallPreviewImage)
			[cell setPlaceImage:place.smallPreviewImage];
		else
			[cell setPlaceImage:nil];
		
		return cell;
	}
	else if(_tableViewUsage == kTableViewAsData && 
			indexPath.row == [_placeManager totalPlacesAtRow:indexPath.section]) {
		
		DWPaginationCell *cell = (DWPaginationCell*)[tableView dequeueReusableCellWithIdentifier:kTVPaginationCellIdentifier];
		
		if(!cell)
			cell = [[DWPaginationCell alloc] initWithStyle:UITableViewStylePlain 
										   reuseIdentifier:kTVPaginationCellIdentifier];
		
		[cell displaySteadyState];
		
		return cell;
	}
	
	else if(_tableViewUsage == kTableViewAsSpinner && 
			indexPath.row == kSpinnerCellIndex) {
		
		DWLoadingCell *cell = (DWLoadingCell*)[tableView dequeueReusableCellWithIdentifier:kTVLoadingCellIdentifier];
		
		if (!cell) 
			cell = [[[DWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault 
										 reuseIdentifier:kTVLoadingCellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
		[cell.spinner startAnimating];
		
		return cell;
	}
	else if(_tableViewUsage == kTableViewAsMessage && 
			indexPath.row == kMessageCellIndex) {
		
		DWMessageCell *cell = (DWMessageCell*)[tableView dequeueReusableCellWithIdentifier:kTVMessageCellIdentifier];
		
		if (!cell) 
			cell = [[[DWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault 
										 reuseIdentifier:kTVMessageCellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
		cell.textLabel.text = self.messageCellText;
		
		return cell;
	}
	else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTVDefaultCellIdentifier];
		
		if (!cell) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:kTVDefaultCellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	
	return cell;	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIScrollViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{		
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

//----------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
    if (!decelerate && _tableViewUsage == kTableViewAsData)
		[self loadImagesForOnscreenRows];
}

//----------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if(_tableViewUsage == kTableViewAsData)
		[self loadImagesForOnscreenRows];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate


//----------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(_tableViewUsage == kTableViewAsData && 
		(self.searchDisplayController.isActive || 
			indexPath.row < [_placeManager totalPlacesAtRow:indexPath.section]) ) {
		
		DWPlace *place = self.searchDisplayController.isActive ? 
						[_placeManager getFilteredPlace:indexPath.row] :
						[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		[_delegate placeSelected:place];
		
		/**
		 *Deselect the currently selected row 
		 */
		if(self.searchDisplayController.isActive)
			[self.searchDisplayController.searchResultsTableView 
				deselectRowAtIndexPath:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] animated:YES];
		else
			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
	else if(_tableViewUsage == kTableViewAsData && 
			!self.searchDisplayController.isActive && 
			indexPath.row == [_placeManager totalPlacesAtRow:indexPath.section]) {
		
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		DWPaginationCell *cell = (DWPaginationCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		
		if(!cell.isInLoadingState) {
			[cell displayProcessingState];
			[self loadNextPageOfPlaces];
		}
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UISearchBarDelegate

//----------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {	
	
	if(!_isLocalSearch)
		[self searchPlaces:self.searchDisplayController.searchBar.text];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UISearchDisplayControllerDelegate 

//----------------------------------------------------------------------------------------------------
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString {
	
	if(_isLocalSearch)
		[_placeManager filterPlacesForSearchText:searchString];
	else {
		[self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor blackColor]];
		[self.searchDisplayController.searchResultsTableView setRowHeight:kSearchPlaceActiveCellHeight];
		
		self.searchDisplayController.searchResultsTableView.alpha			= kSearchActiveAlpha;
		self.searchDisplayController.searchResultsTableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
		
		for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) { 
			[subview removeFromSuperview]; 
		}
	}
	
	return _isLocalSearch;
}

//----------------------------------------------------------------------------------------------------
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[_placeManager clearFilteredPlaces:_isLocalSearch]; 
}

@end

