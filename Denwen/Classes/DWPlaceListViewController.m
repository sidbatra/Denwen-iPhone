//
//  DWPlaceListViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlaceListViewController.h"

//Declarations for private methods
//
@interface DWPlaceListViewController () 

- (void)loadImagesForOnscreenRows;
- (void)searchPlaces:(NSString*)query;

@end



@implementation DWPlaceListViewController

@synthesize messageCellText=_messageCellText,lastDateRefresh=_lastDataRefresh,refreshHeaderView=_refreshHeaderView;



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil searchType:(BOOL)isLocalSearch 
		 withCapacity:(NSInteger)capacity andDelegate:(id)delegate {
		
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {
		
		_placeManager = [[DWPlaceManager alloc] initWithCapacity:capacity];
		_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
		_searchRequestManager = [[DWRequestManager alloc] initWithDelegate:self andInstanceID:SEARCH_INSTANCE_ID];
		
		_delegate = delegate;
		_isLocalSearch = isLocalSearch;
		
		_reloading = NO;
		_isLoadedOnce = NO;
		
		[self resetPagination];
		_tableViewUsage = TABLE_VIEW_AS_SPINNER;
				
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallPlacePreviewDone:) 
													 name:N_SMALL_PLACE_PREVIEW_DONE
												   object:nil];
	}
	return self;
}

	
// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	self.view.hidden = YES;

	CGRect frame = self.view.frame;
	frame.origin.y = 0; 
	self.view.frame = frame;
	
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.tableView setSeparatorColor:[UIColor colorWithRed:0.921 green:0.921 blue:0.921 alpha:1.0]];

	
	self.searchDisplayController.searchBar.placeholder = @"Search All Places";
	[self.tableView setContentOffset:CGPointMake(0,44) animated:NO]; //Tuck the search bar above the table view
	
	
	EGORefreshTableHeaderView *tempRefreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																						 0.0f - self.tableView.bounds.size.height,
																						 self.view.frame.size.width,
																						 self.tableView.bounds.size.height)];
	self.refreshHeaderView = tempRefreshView;
	[tempRefreshView release];
	
	self.refreshHeaderView.delegate = self;
	[self.tableView addSubview:self.refreshHeaderView];
}


// Called when the controller becomes selected in the container
//
- (void)viewIsSelected {
	self.view.hidden = NO;

	if(!_isLoadedOnce) {
		[self loadPlaces];
		_isLoadedOnce = YES;
	}
}


// Called when the controller is deselected from the container
//
- (void)viewIsDeselected {
	[self.searchDisplayController.searchBar resignFirstResponder];
	self.view.hidden = YES;
}


// Reset pagination before a full refresh. Current page is reset to initial value and
// the pagination cell is reintroduced
//
- (void)resetPagination {
	_currentPage = INITIAL_PAGE_FOR_REQUESTS;
	_paginationCellStatus = 1;
}


// Mark end of pagination by setting the flag to remove the pagination cell
//
- (void)markEndOfPagination {
	_paginationCellStatus = 0;
}


// Add a new place to the table view
//
- (void)addNewPlace:(DWPlace*)place {
	if(_tableViewUsage != TABLE_VIEW_AS_DATA) {
		_tableViewUsage = TABLE_VIEW_AS_DATA;
		[self.tableView reloadData];
	}
	
	//Insert the place 
	[_placeManager addPlace:place atRow:0 andColumn:0];
	
	// Insert new row to display the freshly created place
	NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	NSArray *indexPaths = [[NSArray alloc] initWithObjects:placeIndexPath,nil];
	
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
	[indexPaths release];
}



#pragma mark -
#pragma mark Methods to obtain places from the server

// Takes the UI into spinner mode and reloads everything
//
- (void)hardRefresh {
	_reloading = YES;
	
	_tableViewUsage = TABLE_VIEW_AS_SPINNER;
	[self.tableView reloadData];
	
	[self loadPlaces];
}


// Update the lastDateRefresh variable
//
- (void)loadPlaces {

	NSDate *tempDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	self.lastDateRefresh = tempDate;
	[tempDate release];
}


// Increment the pagination counter and load the next page of places
//
- (void)loadNextPageOfPlaces {
	_prePaginationCellCount = [_placeManager totalPlacesAtRow:0];
	_currentPage++;
	[self loadPlaces];
}




// Lets autoRefreshView know that loading is done
//
- (void)finishedLoadingPlaces {
	[self.refreshHeaderView refreshLastUpdatedDate];
	
	if([_placeManager totalPlacesAtRow:0] < PLACES_PER_PAGE || 
	   ([_placeManager totalPlacesAtRow:0] - _prePaginationCellCount < PLACES_PER_PAGE && !_reloading)) { 
		//Mark end of pagination is no new items were found
		_prePaginationCellCount = 0;
		[self markEndOfPagination];
	}

	if(_reloading) {
		[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
		_reloading = NO;
	}
}


// Send a request to search places based on the given query
//
- (void)searchPlaces:(NSString*)query {
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {	
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
}






#pragma mark -
#pragma mark Notification handlers

// Fired when a place has downloaded a small preview image
//
- (void)smallPlacePreviewDone:(NSNotification*)notification {

	if(_tableViewUsage != TABLE_VIEW_AS_DATA || !_isLoadedOnce)
		return;
		
	
	DWPlace *placeWithImage =  (DWPlace*)[notification object];
	
	NSArray *visiblePaths = self.searchDisplayController.isActive ? 
							[self.searchDisplayController.searchResultsTableView indexPathsForVisibleRows] :
							[self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWPlace *place = self.searchDisplayController.isActive ? 
							[_placeManager getFilteredPlace:indexPath.row] :
							[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		if(place == placeWithImage) {
			DWPlaceFeedCell *cell = nil;
			
			if(self.searchDisplayController.isActive)
				cell = (DWPlaceFeedCell*)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
			else	
				cell = (DWPlaceFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			
			cell.placeImage.image = placeWithImage.smallPreviewImage;
		}
	}	
	
}




#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods


// Pull to refresh triggered
//
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	if(!self.searchDisplayController.isActive) {
		[self resetPagination];
		
		_reloading = YES;
		[self loadPlaces];
	}
}


// Returns the status of the data source loading
//
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; 
}


// Returns the last refresh date
//
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return self.lastDateRefresh;
}



#pragma mark -
#pragma mark Table view data source


// The nearby feed table has only 1 section.
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Number of rows in the table is same as the number of items downloaded
// from the server for nearby places.
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA)
		rows = self.searchDisplayController.isActive ? [_placeManager totalFilteredPlaces] : [_placeManager totalPlacesAtRow:section] + _paginationCellStatus;
	else
		rows = LOADING_CELL_COUNT;
		
	return rows;
}


// Calculates the height of cells based on the data within them
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && 
			(self.searchDisplayController.isActive || indexPath.row < [_placeManager totalPlacesAtRow:indexPath.section]) )
		height = PLACE_FEED_CELL_HEIGHT;
	else if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == [_placeManager totalPlacesAtRow:indexPath.section])
		height = PAGINATION_CELL_HEIGHT;
	else
		height = LOADING_CELL_HEIGHT;
	
	return height;
}


// Customize the appearance of table view cells.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && 
			(self.searchDisplayController.isActive || indexPath.row < [_placeManager totalPlacesAtRow:indexPath.section]) ) {
		DWPlace *place = self.searchDisplayController.isActive && tableView == self.searchDisplayController.searchResultsTableView ? 
		[_placeManager getFilteredPlace:indexPath.row] :
		[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		
		DWPlaceFeedCell *cell = (DWPlaceFeedCell*)[tableView dequeueReusableCellWithIdentifier:PLACE_FEED_CELL_IDENTIFIER];
		if (!cell) 
			cell = [[[DWPlaceFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PLACE_FEED_CELL_IDENTIFIER] autorelease];
		
		
		//Customize the cell.
		cell.placeName.text = place.name;
		cell.placeDetails.text = [place displayAddress];
		
		if (!tableView.dragging && !tableView.decelerating)
			[place startSmallPreviewDownload];
		
		
		if (place.smallPreviewImage)
			cell.placeImage.image = place.smallPreviewImage;
		else
			cell.placeImage.image = [UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME];
		
		return cell;
	}
	else if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == [_placeManager totalPlacesAtRow:indexPath.section]) {
		DWPaginationCell *cell = (DWPaginationCell*)[tableView dequeueReusableCellWithIdentifier:PAGINATION_CELL_IDENTIFIER];
		
		if(!cell)
			cell = [[DWPaginationCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:PAGINATION_CELL_IDENTIFIER];
		
		[cell displaySteadyState];
		
		return cell;
	}
	
	else if(_tableViewUsage == TABLE_VIEW_AS_SPINNER && indexPath.row == SPINNER_CELL_PLACE_INDEX) {
		DWLoadingCell *cell = (DWLoadingCell*)[tableView dequeueReusableCellWithIdentifier:LOADING_CELL_IDENTIFIER];
		
		if (!cell) 
			cell = [[[DWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOADING_CELL_IDENTIFIER] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
		[cell.spinner startAnimating];
		
		return cell;
	}
	else if(_tableViewUsage == TABLE_VIEW_AS_MESSAGE && indexPath.row == MESSAGE_CELL_PLACE_INDEX) {
		DWMessageCell *cell = (DWMessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_CELL_IDENTIFIER];
		
		if (!cell) 
			cell = [[[DWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MESSAGE_CELL_IDENTIFIER] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
		cell.textLabel.text = self.messageCellText;
		
		return cell;
	}
	else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_CELL_IDENTIFIER];
		
		if (!cell) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DEFAULT_CELL_IDENTIFIER] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	
	return cell;	
}


// Refresh the filtered places UI to display results
//
- (void)refreshFilteredPlacesUI {
	[self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
	[self.searchDisplayController.searchResultsTableView setRowHeight:45];
	self.searchDisplayController.searchResultsTableView.alpha = 1.0;
	self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) { [subview removeFromSuperview]; }
	
	if(!_isLocalSearch)
		[self.searchDisplayController.searchResultsTableView reloadData];	
}



#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)



// Alert refreshView about the table scrolling
//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{		
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


// Launch cell preview downloads if the scrollView is decelerating
//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
    if (!decelerate && _tableViewUsage == TABLE_VIEW_AS_DATA)
		[self loadImagesForOnscreenRows];
}


// Launch cell preview downloads if the scrollView is about to stop
// decelerating
//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if(_tableViewUsage == TABLE_VIEW_AS_DATA)
		[self loadImagesForOnscreenRows];
}


// Download preview images for visible cells
//
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



#pragma mark -
#pragma mark Table view delegate


// Handles click event on the table view 
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && 
		(self.searchDisplayController.isActive || indexPath.row < [_placeManager totalPlacesAtRow:indexPath.section]) ) {
		
		DWPlace *place = self.searchDisplayController.isActive ? 
						[_placeManager getFilteredPlace:indexPath.row] :
						[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		[_delegate placeSelected:place];
		
		//Deselect the currently selected row 
		if(self.searchDisplayController.isActive)
			[self.searchDisplayController.searchResultsTableView 
				deselectRowAtIndexPath:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] animated:YES];
		else
			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
	else if(_tableViewUsage == TABLE_VIEW_AS_DATA && !self.searchDisplayController.isActive && indexPath.row == [_placeManager totalPlacesAtRow:indexPath.section]) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		DWPaginationCell *cell = (DWPaginationCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		
		if(!cell.isInLoadingState) {
			[cell displayProcessingState];
			[self loadNextPageOfPlaces];
		}
		
	}

}



#pragma mark -
#pragma mark UISearchBar Delegate Methods


// User clicks the big blue search button
//
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {	
	
	//[self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    //[self.searchDisplayController.searchResultsTableView setRowHeight:45];
	//self.searchDisplayController.searchResultsTableView.alpha = 1.0;
    //self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	//for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) { [subview removeFromSuperview]; }
	
	// Code for a local search
	//[_placeManager filterPlacesForSearchText:self.searchDisplayController.searchBar.text];
	//[self.searchDisplayController.searchResultsTableView reloadData];
	
	if(!_isLocalSearch)
		[self searchPlaces:self.searchDisplayController.searchBar.text];
}



#pragma mark -
#pragma mark UISearchDisplayControllerDelegate 


// Fired when the search text is changed to test if the table should be reloaded
//
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	
	if(_isLocalSearch)
		[_placeManager filterPlacesForSearchText:searchString];
	else {
		[self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor blackColor]];
		self.searchDisplayController.searchResultsTableView.alpha = 0.8;
		[self.searchDisplayController.searchResultsTableView setRowHeight:3000];
		self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		for (UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) { [subview removeFromSuperview]; }
	}

	
	return _isLocalSearch;
}


// Clear previous copy of filtered places when search ends
//
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[_placeManager clearFilteredPlaces:_isLocalSearch]; 
}





#pragma mark -
#pragma mark Memory management

// Handle the view did unload event
//
- (void)viewDidUnload {
	self.refreshHeaderView = nil;
}

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
	
	self.lastDateRefresh = nil;
	self.messageCellText = nil;
	self.refreshHeaderView = nil;
	
	[_placeManager release];
	[_requestManager release];
	[_searchRequestManager release];
	
	[super dealloc];
}


@end

