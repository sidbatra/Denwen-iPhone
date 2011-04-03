//
//  DWItemFeedViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemFeedViewController.h"
#import "DWRequestsManager.h"
#import "DWItemFeedCell.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"
#import "DWPaginationCell.h"
#import "DWConstants.h"

static NSInteger const kItemsPerPage				= 20;
static NSInteger const kDefaultSections				= 1;
static NSInteger const kSpinnerCellIndex			= 2;
static NSInteger const kMessageCellIndex			= 2;
static NSInteger const kMaxFeedCellHeight			= 2000;
static NSString* const kItemFeedCellIdentifier		= @"ItemFeedCell";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedViewController

@synthesize itemManager			= _itemManager;
@synthesize messageCellText		= _messageCellText;
@synthesize lastRefreshDate		= _lastDataRefresh;
@synthesize refreshHeaderView	= _refreshHeaderView;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if (self) {
		
		self.itemManager	= [[[DWItemManager alloc] init] autorelease];
		_isReloading		= NO;
		_isLoadedOnce		= NO;
		_tableViewUsage		= kTableViewAsSpinner;
		_delegate			= delegate;
		
		[self resetPagination];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumAttachmentLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallUserImageLoaded:) 
													 name:kNImgSmallUserLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallPlaceImageLoaded:) 
													 name:kNImgSmallPlaceLoaded
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	CGRect frame	= self.view.frame;
	frame.origin.y	= 0; 
	self.view.frame	= frame;
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	_delegate				= nil;
	self.itemManager		= nil;
	self.messageCellText	= nil;
	self.lastRefreshDate	= nil;
	self.refreshHeaderView	= nil;
    
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewItem:(DWItem *)item 
		   atIndex:(NSInteger)index {
	
	if(_tableViewUsage != kTableViewAsData) {
		_tableViewUsage = kTableViewAsData;
		[self.tableView reloadData];
	}
	
	[_itemManager addItem:item atIndex:index];
	
	/**
	 * Insert the new item into the table view
	 */
	NSIndexPath *itemIndexPath	= [NSIndexPath indexPathForRow:index 
													 inSection:0];
	NSArray *indexPaths			= [NSArray arrayWithObjects:itemIndexPath,nil];
	
	[self.tableView insertRowsAtIndexPaths:indexPaths
						  withRowAnimation:UITableViewRowAnimationRight];
}

//----------------------------------------------------------------------------------------------------
- (void)resetPagination {
	_currentPage			= kPagInitialPage;
	_paginationCellStatus	= 1;
}

//----------------------------------------------------------------------------------------------------
- (void)markEndOfPagination {
	_paginationCellStatus = 0;
}
								   
//----------------------------------------------------------------------------------------------------
- (void)hardRefresh {
   _isReloading		= YES;
   _tableViewUsage	= kTableViewAsSpinner;
	
   [self.tableView reloadData];
   [self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)loadItems {
   self.lastRefreshDate = [NSDate dateWithTimeIntervalSinceNow:0];
}

//----------------------------------------------------------------------------------------------------
- (void)loadNextPageOfItems {
   _prePaginationCellCount = [_itemManager totalItems];
   _currentPage++;
   [self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)finishedLoadingItems {
   [self.refreshHeaderView refreshLastUpdatedDate];
   
   if([_itemManager totalItems] < kItemsPerPage || 
	  ([_itemManager totalItems] - _prePaginationCellCount < kItemsPerPage && 
		!_isReloading)) { 
	   
	   /**
		* Mark end of pagination is no new items were found
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
- (void)loadImagesForOnscreenRows {
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		[item startRemoteImagesDownload];
	}
}

								   
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)smallPlaceImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData || ![_itemManager totalItems])
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.place.databaseID == resourceID) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell setSmallPreviewPlaceImage:[info objectForKey:kKeyImage]];
		}
	}	
}	

//----------------------------------------------------------------------------------------------------
- (void)smallUserImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData || ![_itemManager totalItems])
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.user.databaseID == resourceID) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			cell.userImage.image = [info objectForKey:kKeyImage];
		}
	}	
}

//----------------------------------------------------------------------------------------------------
- (void)mediumAttachmentLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData || ![_itemManager totalItems])
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.attachment.databaseID == resourceID) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell.attachmentImage setBackgroundImage:[info objectForKey:kKeyImage] forState:UIControlStateNormal];	
		}
	}	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate


//----------------------------------------------------------------------------------------------------
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	[self resetPagination];
	
	_isReloading = YES;
	[self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _isReloading; 
}

//----------------------------------------------------------------------------------------------------
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return self.lastRefreshDate;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kDefaultSections;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger totalItems = 0;
	
	if(_tableViewUsage == kTableViewAsData)
		totalItems = [_itemManager totalItems] + _paginationCellStatus;
	else
		totalItems = kTVLoadingCellCount;

    return totalItems;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
		
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [_itemManager totalItems]) {
		
		CGSize textSize = {self.view.frame.size.width - 69, kMaxFeedCellHeight};
		CGSize size = [[_itemManager getItem:indexPath.row].data sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15] 
															constrainedToSize:textSize
																lineBreakMode:UILineBreakModeWordWrap];
		
		NSInteger attachmentHeight = 0;
		
		if ([[_itemManager getItem:indexPath.row] hasAttachment]) 
			attachmentHeight = kAttachmentHeight + kAttachmentYPadding;
		
		height =  size.height + 61 + attachmentHeight;
	}
	else if(_tableViewUsage == kTableViewAsData && indexPath.row == [_itemManager totalItems])
		height = kPaginationCellHeight;
	else 
		height = kTVLoadingCellHeight;
	
	return height;
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	UITableViewCell *cell = nil;
		
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [_itemManager totalItems]) {
		
		DWItem *item			= [_itemManager getItem:indexPath.row];
		DWItemFeedCell *cell	= (DWItemFeedCell*)[tableView dequeueReusableCellWithIdentifier:kItemFeedCellIdentifier];
		
		if(!cell) 
			cell = [[[DWItemFeedCell alloc] initWithStyle:UITableViewCellStyleDefault 
										  reuseIdentifier:kItemFeedCellIdentifier
											   withTarget:self] autorelease];
		
		/** 
		 * Update resused cell
		 */
		[cell updateClassMemberHasAttachment:[item hasAttachment] 
								   andItemID:item.databaseID];
		

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[cell.placeName setTitle:[NSString stringWithFormat:@"at %@", item.place.name] 
						forState:UIControlStateNormal];
		
		/**
		 * Reposition elements on reused cell
		 */
		[cell positionAndCustomizeCellItemsFrom:item.data
									   userName:[item.user fullName]
										andTime:[item createdTimeAgoInWords]];
		
		if (!tableView.dragging && !tableView.decelerating) {
			[item startRemoteImagesDownload];
		}
		
		if ([item hasAttachment]) {
			if (item.attachment.previewImage)
				[cell.attachmentImage setBackgroundImage:item.attachment.previewImage 
												forState:UIControlStateNormal];	
			else
				[cell.attachmentImage setBackgroundImage:[UIImage imageNamed:kImgGenericPlaceHolder] 
												forState:UIControlStateNormal];	
			
			if([item.attachment isVideo])
				[cell displayPlayIcon];
		}
		
		if (item.place.smallPreviewImage)
			[cell setSmallPreviewPlaceImage:item.place.smallPreviewImage];
		else
			[cell setSmallPreviewPlaceImage:[UIImage imageNamed:kImgGenericPlaceHolder]];
		
		if (item.user.smallPreviewImage)
			cell.userImage.image = item.user.smallPreviewImage;
		else
			cell.userImage.image = [UIImage imageNamed:kImgGenericPlaceHolder];
		
		return cell;
	}
	else if(_tableViewUsage == kTableViewAsData && indexPath.row == [_itemManager totalItems]) {
		DWPaginationCell *cell = (DWPaginationCell*)[tableView dequeueReusableCellWithIdentifier:kTVPaginationCellIdentifier];
		
		if(!cell)
			cell = [[DWPaginationCell alloc] initWithStyle:UITableViewStylePlain
										   reuseIdentifier:kTVPaginationCellIdentifier];
		
		[cell displaySteadyState];
		
		return cell;
	}
	else if(_tableViewUsage == kTableViewAsSpinner && indexPath.row == kSpinnerCellIndex) {
		DWLoadingCell *cell = (DWLoadingCell*)[tableView dequeueReusableCellWithIdentifier:kTVLoadingCellIdentifier];
		
		if (!cell) 
			cell = [[[DWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:kTVLoadingCellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.spinner startAnimating];
		
		return cell;
	}
	else if((_tableViewUsage == kTableViewAsMessage || _tableViewUsage == kTableViewAsProfileMessage) && indexPath.row == kMessageCellIndex) {
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
	
	/**
	 * Launch pagination when load more cell is clicked
	 */
	if(_tableViewUsage == kTableViewAsData && indexPath.row == [_itemManager totalItems]) {
		
		[self.tableView deselectRowAtIndexPath:indexPath
									  animated:YES];

		DWPaginationCell *cell = (DWPaginationCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		
		if(!cell.isInLoadingState) {
			[cell displayProcessingState];
			[self loadNextPageOfItems];
		}
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIItemFeedCellDelegate

//----------------------------------------------------------------------------------------------------
- (void)didTapPlaceName:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:((UIButton*)sender).tag 
											  atRow:kMPItemsIndex];
	
	[_delegate placeSelected:item.place];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapPlaceImage:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:((UIButton*)sender).tag
											  atRow:kMPItemsIndex];
	
	[_delegate placeSelected:item.place];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapUserImage:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:((UIButton*)sender).tag 
											  atRow:kMPItemsIndex];
	
	[_delegate userSelected:item.user];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapAttachmentImage:(id)sender event:(id)event {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:((UIButton*)sender).tag
											  atRow:kMPItemsIndex];
	
	[_delegate attachmentSelected:item.attachment.fileURL
				  withIsImageType:[item.attachment isImage]];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapUrl:(id)sender event:(id)event {
	NSInteger tag	= ((UIButton*)sender).tag;
	DWItem *item	= (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:(tag/kURLTagMultipler) 
												 atRow:kMPItemsIndex];
	
	[_delegate urlSelected:[item.urls objectAtIndex:tag % kURLTagMultipler]];
}


@end

