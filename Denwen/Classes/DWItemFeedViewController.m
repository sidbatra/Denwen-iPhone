//
//  DWItemFeedViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemFeedViewController.h"
#import "DWRequestsManager.h"
#import "DWMemoryPool.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"
#import "DWPaginationCell.h"
#import "DWConstants.h"

static NSInteger const kItemsPerPage				= 20;
static NSInteger const kDefaultSections				= 1;
static NSInteger const kSpinnerCellIndex			= 0;
static NSInteger const kMessageCellIndex			= 2;
static NSInteger const kMaxFeedCellHeight			= 2000;
static NSInteger const kItemFeedCellHeight			= 320;
static NSString* const kItemFeedCellIdentifier		= @"ItemFeedCell";
static NSString* const kMsgActionSheetCancel        = @"Cancel";
static NSString* const kMsgActionSheetDelete		= @"Delete";



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
		
		self.itemManager	= [[[DWItemsManager alloc] init] autorelease];
		_isReloading		= NO;
		_isLoadedOnce		= NO;
        _isLoadingPage      = NO;
		_tableViewUsage		= kTableViewAsSpinner;
		_delegate			= delegate;
		
		[self resetPagination];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumAttachmentLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {

	CGRect frame		= self.view.frame;
	frame.origin.y		= 0; 
	frame.size.height	= frame.size.height; 
	self.view.frame		= frame;
	
	self.tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor	= [UIColor blackColor];
	
	self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																						  0.0f - self.tableView.bounds.size.height,
																						  self.view.frame.size.width,
																						  self.tableView.bounds.size.height)] autorelease];
	self.refreshHeaderView.delegate = self;
	
	[self.refreshHeaderView applyBackgroundImage:nil 
								   withFadeImage:nil
							 withBackgroundColor:[UIColor blackColor]];

	[self.tableView addSubview:self.refreshHeaderView];	
    
    
    UISwipeGestureRecognizer *swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                                      action:@selector(handleSwipeGesture:)] 
                                            autorelease];
    
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRight];
    
    
    UISwipeGestureRecognizer *swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                                     action:@selector(handleSwipeGesture:)] 
                                           autorelease];
    
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeLeft];
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
    [self resetPagination];
    
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
    _isLoadingPage = YES;
    
    [self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)finishedLoadingItems {
   [self.refreshHeaderView refreshLastUpdatedDate];
   
   if([_itemManager totalItems] < kItemsPerPage || 
	  ([_itemManager totalItems] - _prePaginationCellCount < kItemsPerPage && 
		!_isReloading)) { 
	   
	   /**
		* Mark end of pagination if no new items were found
		*/
	   _prePaginationCellCount = 0;
	   [self markEndOfPagination];
   }
   
   if(_isReloading) {
	   [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	   _isReloading = NO;
   }
   _isLoadingPage = NO;
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
-(void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        
        if ([[_itemManager getItem:swipedIndexPath.row].user isCurrentUser]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                     delegate:self 
                                                            cancelButtonTitle:kMsgActionSheetCancel
                                                       destructiveButtonTitle:kMsgActionSheetDelete
                                                            otherButtonTitles:nil];
            
            [actionSheet showInView:[_delegate requestCustomTabBarController].view];
            actionSheet.tag = swipedIndexPath.row;
            [actionSheet release];    
        }
    }
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIActionSheet Delegate
//----------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	if (buttonIndex == 0) {
        NSLog(@"deleted cell %d",actionSheet.tag);
    }
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
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
            [cell setItemImage:[info objectForKey:kKeyImage]];
            [cell redisplay];
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
		
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [_itemManager totalItems])
		height = kItemFeedCellHeight;
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
										  reuseIdentifier:kItemFeedCellIdentifier] autorelease];
		
	
		cell.delegate			= self;
		
		cell.itemID				= item.databaseID;
		cell.itemData			= item.data;
		cell.itemPlaceName		= item.place.name;
		cell.itemUserName		= item.user.firstName;
		
		[cell setDetails:item.touchesCount 
			andCreatedAt:[item createdTimeAgoInWords]];
			
		
		//if (!tableView.dragging && !tableView.decelerating)
			[item startRemoteImagesDownload];

        
        if (item.attachment) {
			[cell setItemImage:item.attachment.previewImage];
			
			if([item.attachment isVideo])
				cell.attachmentType = kAttachmentVideo;
			else if([item.attachment isImage])
				cell.attachmentType = kAttachmentImage;
		}
		else {
			[cell setItemImage:nil];
			
			cell.attachmentType = kAttachmentNone;
		}
        
		[cell reset];
		[cell redisplay];
		
		return cell;
	}
	else if(_tableViewUsage == kTableViewAsData && indexPath.row == [_itemManager totalItems]) {
		DWPaginationCell *cell = (DWPaginationCell*)[tableView dequeueReusableCellWithIdentifier:kTVPaginationCellIdentifier];
		
		if(!cell)
			cell = [[DWPaginationCell alloc] initWithStyle:UITableViewStylePlain
										   reuseIdentifier:kTVPaginationCellIdentifier];
		
        [cell displayProcessingState];
        
        if (!_isLoadingPage) 
            [self loadNextPageOfItems];

		return cell;
	}
	else if(_tableViewUsage == kTableViewAsSpinner && indexPath.row == kSpinnerCellIndex) {
		DWLoadingCell *cell = (DWLoadingCell*)[tableView dequeueReusableCellWithIdentifier:kTVLoadingCellIdentifier];
		
		if (!cell) 
			cell = [[[DWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:kTVLoadingCellIdentifier] autorelease];
		
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
#pragma mark DWItemFeedCellDelegate

//----------------------------------------------------------------------------------------------------
- (BOOL)shouldTouchItemWithID:(NSInteger)itemID {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	return !item.isTouched && ![item.user isCurrentUser];
}

//----------------------------------------------------------------------------------------------------
- (void)cellTouched:(NSInteger)itemID {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	item.isTouched = YES;
	
	[[DWRequestsManager sharedDWRequestsManager] createTouch:itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)placeSelectedForItemID:(NSInteger)itemID {

	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	[_delegate placeSelected:item.place];
}

//----------------------------------------------------------------------------------------------------
- (void)userSelectedForItemID:(NSInteger)itemID {
	
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	[_delegate userSelected:item.user];
}

//----------------------------------------------------------------------------------------------------
- (void)shareSelectedForItemID:(NSInteger)itemID {
	NSLog(@"shared seleced for %d",itemID);
}

//----------------------------------------------------------------------------------------------------
- (NSString*)getVideoAttachmentURLForItemID:(NSInteger)itemID {
    DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
    return item.attachment.fileURL;
}

//----------------------------------------------------------------------------------------------------
- (UIViewController*)requestCustomTabBarController {
	return [_delegate requestCustomTabBarController];
}

/*
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
*/

@end

