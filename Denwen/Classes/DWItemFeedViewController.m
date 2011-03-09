//
//  DWNearbyViewController.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemFeedViewController.h"

//Declarations for private methods
//
@interface DWItemFeedViewController () 

- (void)loadImagesForOnscreenRows;

@end


@implementation DWItemFeedViewController


@synthesize messageCellText=_messageCellText,lastDateRefresh=_lastDataRefresh,refreshHeaderView=_refreshHeaderView;



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if (self) {
		_itemManager = [[DWItemManager alloc] init];
		_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
		
		[self resetPagination];
		
		_reloading = NO;
		_isLoadedOnce = NO;
		
		_delegate = delegate;
		_tableViewUsage = TABLE_VIEW_AS_SPINNER;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallPlacePreviewDone:) 
													 name:N_SMALL_PLACE_PREVIEW_DONE
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallUserPreviewDone:) 
													 name:N_SMALL_USER_PREVIEW_DONE
												   object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(attachmentPreviewDone:) 
													 name:N_ATTACHMENT_PREVIEW_DONE
												   object:nil];			
	}
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	CGRect frame = self.view.frame;
	frame.origin.y = 0; 
	self.view.frame = frame;
	
	[self.tableView setSeparatorColor:[UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.0]];
	
	
	EGORefreshTableHeaderView *tempRefreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																											 0.0f - self.tableView.bounds.size.height,
																											 self.view.frame.size.width,
																											 self.tableView.bounds.size.height)];
	self.refreshHeaderView = tempRefreshView;
	[tempRefreshView release];
	
	self.refreshHeaderView.delegate = self;
	[self.tableView addSubview:self.refreshHeaderView];	
}


// Add a new item to the table view
//
- (void)addNewItem:(DWItem *)item atIndex:(NSInteger)index {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA) {
		_tableViewUsage = TABLE_VIEW_AS_DATA;
		[self.tableView reloadData];
	}
	
	//Insert the item into the items array
	[_itemManager addItem:item atIndex:index];
	
	// Insert new row to display the freshly created item
	NSIndexPath *itemIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
	NSArray *indexPaths = [[NSArray alloc] initWithObjects:itemIndexPath,nil];
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
	
	[indexPaths release];
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


#pragma mark -
#pragma mark Notification handlers

// Fired when a place has downloaded a small preview image
//
- (void)smallPlacePreviewDone:(NSNotification*)notification {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA || ![_itemManager totalItems])
		return;

	DWPlace *place =  (DWPlace*)[notification object];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];

	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.place == place) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell setSmallPreviewPlaceImage:place.smallPreviewImage];
		}
	}	
	
}



// Fired when a small user preview image has downloaded
//
- (void)smallUserPreviewDone:(NSNotification*)notification {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA || ![_itemManager totalItems])
		return;
	
	DWUser *user = (DWUser*)[notification object];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.user == user) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			cell.userImage.image = user.smallPreviewImage;
		}
	}	
}


// Fired when an attachment preview is downloaded
//
- (void)attachmentPreviewDone:(NSNotification*)notification {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA || ![_itemManager totalItems])
		return;
	
	DWAttachment *attachment = (DWAttachment*)[notification object];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.attachment == attachment) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell.attachmentImage setBackgroundImage:attachment.previewImage forState:UIControlStateNormal];	
		}
	}	
}



#pragma mark -
#pragma mark DWRequestManagerDelegate


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
#pragma mark Data Source Loading 


// Takes the UI into spinner mode and reloads everything
//
- (void)hardRefresh {
	_reloading = YES;
	
	_tableViewUsage = TABLE_VIEW_AS_SPINNER;
	[self.tableView reloadData];
	
	[self loadItems];
}


// Update the refreshed at date before loading items
//
- (BOOL)loadItems {

	NSDate *tempDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	self.lastDateRefresh = tempDate;
	[tempDate release];
	
	return YES;
}


// Increment the pagination counter and load the next page of items
//
- (void)loadNextPageOfItems {
	_prePaginationCellCount = [_itemManager totalItems];
	_currentPage++;
	[self loadItems];
}


// Lets autoRefreshView know that loading is done
//
- (void)finishedLoadingItems {
	[self.refreshHeaderView refreshLastUpdatedDate];
	
	if([_itemManager totalItems] < ITEMS_PER_PAGE || 
		([_itemManager totalItems] - _prePaginationCellCount < ITEMS_PER_PAGE && !_reloading)) { 
		//Mark end of pagination is no new items were found
		_prePaginationCellCount = 0;
		[self markEndOfPagination];
	}
	
	if(_reloading) {
		[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
		_reloading = NO;
	}

}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods


// Pull to refresh triggered
//
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	[self resetPagination];
	
	_reloading = YES;
	[self loadItems];
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
	NSInteger totalItems = 0;
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA)
		totalItems = [_itemManager totalItems] + _paginationCellStatus;
	else
		totalItems = LOADING_CELL_COUNT;

    return totalItems;
}


// Calculates the height of cells based on the data within them
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
		
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row < [_itemManager totalItems]) {
		
		CGSize textSize = {self.view.frame.size.width - 69, MAX_DYNAMIC_CELL_HEIGHT };
		CGSize size = [[_itemManager getItem:indexPath.row].data sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15] 
															constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
		
		NSInteger attachmentHeight = 0;
		if ([[_itemManager getItem:indexPath.row] hasAttachment]) 
			attachmentHeight = ATTACHMENT_HEIGHT + ATTACHMENT_Y_PADDING;
		
		height =  size.height + 61 + attachmentHeight;
	}
	else if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == [_itemManager totalItems])
		height = PAGINATION_CELL_HEIGHT;
	else 
		height = LOADING_CELL_HEIGHT;
	
	return height;
}


// Customize the appearance of table view cells.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	UITableViewCell *cell = nil;
		
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row < [_itemManager totalItems]) {
		
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		DWItemFeedCell *cell = (DWItemFeedCell*)[tableView dequeueReusableCellWithIdentifier:ITEM_FEED_CELL_IDENTIFIER];
		
		if(!cell) 
			cell = [[[DWItemFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ITEM_FEED_CELL_IDENTIFIER
											   withTarget:self] autorelease];
		
		//update the class members
		[cell updateClassMemberHasAttachment:[item hasAttachment] andItemID:item.databaseID];

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.placeName setTitle:[NSString stringWithFormat:@"at %@", item.place.name] forState:UIControlStateNormal];
		
		//position cell items;
		[cell positionAndCustomizeCellItemsFrom:item.data userName:[item.user fullName] andTime:[item createdTimeAgoInWords]];
		
		if (!tableView.dragging && !tableView.decelerating) {
			[item startRemoteImagesDownload];
		}
		
		//Test if the preview images got pulled from the cache instantly
		if ([item hasAttachment]) {
			if (item.attachment.previewImage) {
				[cell.attachmentImage setBackgroundImage:item.attachment.previewImage forState:UIControlStateNormal];	
			}
			else
				[cell.attachmentImage setBackgroundImage:[UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME] forState:UIControlStateNormal];	
		}
		if (item.place.smallPreviewImage)
			[cell setSmallPreviewPlaceImage:item.place.smallPreviewImage];
		else
			[cell setSmallPreviewPlaceImage:[UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME]];
		
		if (item.user.smallPreviewImage)
			cell.userImage.image = item.user.smallPreviewImage;
		else
			cell.userImage.image = [UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME];
		
		
		return cell;
	}
	else if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == [_itemManager totalItems]) {
		DWPaginationCell *cell = (DWPaginationCell*)[tableView dequeueReusableCellWithIdentifier:PAGINATION_CELL_IDENTIFIER];
		
		if(!cell)
			cell = [[DWPaginationCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:PAGINATION_CELL_IDENTIFIER];
		
		[cell displaySteadyState];
		
		return cell;
	}
	else if(_tableViewUsage == TABLE_VIEW_AS_SPINNER && indexPath.row == SPINNER_CELL_INDEX) {
		DWLoadingCell *cell = (DWLoadingCell*)[tableView dequeueReusableCellWithIdentifier:LOADING_CELL_IDENTIFIER];
		
		if (!cell) 
			cell = [[[DWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LOADING_CELL_IDENTIFIER] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.spinner startAnimating];
		
		return cell;
	}
	else if((_tableViewUsage == TABLE_VIEW_AS_MESSAGE || _tableViewUsage == TABLE_VIEW_AS_PROFILE_MESSAGE) && indexPath.row == MESSAGE_CELL_INDEX) {
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



#pragma mark -
#pragma mark UIScrollViewDelegate


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
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		[item startRemoteImagesDownload];
	}
}



#pragma mark -
#pragma mark Table view delegate


// Handles click event on the table view 
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Load more cell is clicked
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == [_itemManager totalItems]) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

		DWPaginationCell *cell = (DWPaginationCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		
		if(!cell.isInLoadingState) {
			[cell displayProcessingState];
			[self loadNextPageOfItems];
		}
	}
}




#pragma mark -
#pragma mark Cell Click events

// User clicks a place name
//
- (void)didTapPlaceName:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[DWMemoryPool getObject:((UIButton*)sender).tag atRow:ITEMS_INDEX];
	[_delegate placeSelected:item.place.hashedId];
}


// User clicks a place image
//
- (void)didTapPlaceImage:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[DWMemoryPool getObject:((UIButton*)sender).tag atRow:ITEMS_INDEX];
	[_delegate placeSelected:item.place.hashedId];
}


// User clicks a user Image
//
- (void)didTapUserImage:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[DWMemoryPool getObject:((UIButton*)sender).tag atRow:ITEMS_INDEX];
	[_delegate userSelected:item.user.databaseID];
}


// User clicks an attachment
//
- (void)didTapAttachmentImage:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[DWMemoryPool getObject:((UIButton*)sender).tag atRow:ITEMS_INDEX];
	[_delegate attachmentSelected:item.attachment.fileUrl];
}


// User clicks on the url
//
- (void)didTapUrl:(id)sender event:(id)event {
	NSInteger tag = ((UIButton*)sender).tag;
	DWItem *item = (DWItem*)[DWMemoryPool getObject:(tag/URL_TAG_MULTIPLIER) atRow:ITEMS_INDEX];
	[_delegate urlSelected:[item.urls objectAtIndex:tag % URL_TAG_MULTIPLIER]];
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
	_delegate = nil;
	
	self.messageCellText = nil;
	self.lastDateRefresh = nil;
	self.refreshHeaderView = nil;
	
	[_itemManager release];
	[_requestManager release];
    
	[super dealloc];
}


@end

