//
//  DWTableViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTableViewController.h"
#import "DWPaginationCell.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"
#import "DWConstants.h"

static NSInteger const kDefaultSections				= 1;
static NSInteger const kMessageCellIndex			= 0;
static NSInteger const kSpinnerCellIndex			= 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTableViewController

@synthesize messageCellText     = _messageCellText;
@synthesize refreshHeaderView   = _refreshHeaderView;

//----------------------------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    
    if (self) {
        
        _dataSourceDelegate     = self;
        _tableViewUsage			= kTableViewAsSpinner;
		_isReloading			= NO;
        _isLoadingPage          = NO;
		
		[self resetPagination];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.messageCellText	= nil;
	self.refreshHeaderView	= nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor          = [UIColor blackColor];
	self.tableView.separatorStyle           = UITableViewCellSeparatorStyleNone;
    
    self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																						  0.0f - self.tableView.bounds.size.height,
																						  self.view.frame.size.width,
																						  self.tableView.bounds.size.height)] autorelease];
	self.refreshHeaderView.delegate = self;
    
    
	[self.refreshHeaderView applyBackgroundImage:nil 
								   withFadeImage:nil
							 withBackgroundColor:[UIColor colorWithRed:0.1764
                                                                 green:0.1764 
                                                                  blue:0.1764
                                                                 alpha:1.0]];
    
	[self.tableView addSubview:self.refreshHeaderView];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.refreshHeaderView   = nil;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)resetPagination {
	_currentPage            = kPagInitialPage;
	_paginationCellStatus   = 1;
}

//----------------------------------------------------------------------------------------------------
- (void)markEndOfPagination {
	_paginationCellStatus = 0;
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows {
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths)
        [_dataSourceDelegate loadImagesForDataRowAtIndex:indexPath];
}

//----------------------------------------------------------------------------------------------------
- (void)loadNextPage {
	_prePaginationCellCount = [_dataSourceDelegate numberOfDataRows];
	_currentPage++;
    _isLoadingPage = YES;
	
    [_dataSourceDelegate loadData];
}

//----------------------------------------------------------------------------------------------------
- (void)finishedLoading {
	[self.refreshHeaderView refreshLastUpdatedDate];
	
	if([_dataSourceDelegate numberOfDataRows] < [_dataSourceDelegate numberOfDataRowsPerPage] || 
	   ([_dataSourceDelegate numberOfDataRows] - _prePaginationCellCount < [_dataSourceDelegate numberOfDataRowsPerPage] &&
        !_isReloading)) { 
           
           /**
            * Mark end of pagination is no new rows are found
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
- (void)hardRefresh {
    [self resetPagination];
    
    _isReloading		= YES;
    _tableViewUsage     = kTableViewAsSpinner;
	
    [self.tableView reloadData];
    [_dataSourceDelegate loadData];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewDataRowAt:(NSInteger)index {
	
	if(_tableViewUsage != kTableViewAsData) {
		_tableViewUsage = kTableViewAsData;
		[self.tableView reloadData];
	}
	
	NSIndexPath *touchIndexPath = [NSIndexPath indexPathForRow:index
													 inSection:0];
	NSArray *indexPaths			= [NSArray arrayWithObjects:touchIndexPath,nil];
	
	[self.tableView insertRowsAtIndexPaths:indexPaths
						  withRowAnimation:UITableViewRowAnimationRight];
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
    
	NSInteger rows = 0;
	
	if(_tableViewUsage == kTableViewAsData)
		rows = [_dataSourceDelegate  numberOfDataRows] + _paginationCellStatus;
	else
		rows = kTVLoadingCellCount;
    
	return rows;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CGFloat height = 0;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [_dataSourceDelegate numberOfDataRows])
		height = [_dataSourceDelegate heightForDataRows];
	
	else if(_tableViewUsage == kTableViewAsData && indexPath.row == [_dataSourceDelegate numberOfDataRows])
		height = kPaginationCellHeight;
	else
		height = kTVLoadingCellHeight;
	
	return height;
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if(_tableViewUsage == kTableViewAsData && indexPath.row < [_dataSourceDelegate numberOfDataRows]) {
        return  [_dataSourceDelegate cellForDataRowAt:indexPath
                                          inTableView:tableView];
    }
    if(_tableViewUsage == kTableViewAsData && indexPath.row == [_dataSourceDelegate numberOfDataRows]) {
		
		DWPaginationCell *cell = (DWPaginationCell*)[tableView dequeueReusableCellWithIdentifier:kTVPaginationCellIdentifier];
		
		if(!cell)
			cell = [[DWPaginationCell alloc] initWithStyle:UITableViewStylePlain 
										   reuseIdentifier:kTVPaginationCellIdentifier];
		
        [cell displayProcessingState];
        if (!_isLoadingPage) 
            [self loadNextPage];
		
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
	else if(_tableViewUsage == kTableViewAsMessage && indexPath.row == kMessageCellIndex) {
		
		DWMessageCell *cell = (DWMessageCell*)[tableView dequeueReusableCellWithIdentifier:kTVMessageCellIdentifier];
		
		if (!cell) 
			cell = [[[DWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault 
										 reuseIdentifier:kTVMessageCellIdentifier] autorelease];
		
		cell.messageLabel.text = self.messageCellText;
		
		return cell;
	}
	else {
        cell = [tableView dequeueReusableCellWithIdentifier:kTVDefaultCellIdentifier];
		
		if (!cell) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:kTVDefaultCellIdentifier] autorelease];
		
		cell.selectionStyle					= UITableViewCellSelectionStyleNone;
		cell.contentView.backgroundColor	= [UIColor blackColor];
		
		return cell;
	}
	
	return cell;	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row < [_dataSourceDelegate numberOfDataRows]) {
        [_dataSourceDelegate didSelectDataRowAt:indexPath
                                    inTableView:tableView];
    }
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
#pragma mark EGORefreshTableHeaderDelegate 

//----------------------------------------------------------------------------------------------------
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self resetPagination];
    
    _isReloading = YES;
    [_dataSourceDelegate loadData];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _isReloading; 
}

//----------------------------------------------------------------------------------------------------
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return nil;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRows {
    return 0;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRowsPerPage {
    return 0;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)heightForDataRows {
    return 0;
}

//----------------------------------------------------------------------------------------------------
- (void)loadData {
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForDataRowAtIndex:(NSIndexPath *)indexPath {
    
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell*)cellForDataRowAt:(NSIndexPath *)indexPath
                         inTableView:(UITableView*)tableView {
    return nil;
}

//----------------------------------------------------------------------------------------------------
- (void)didSelectDataRowAt:(NSIndexPath*)indexPath
               inTableView:(UITableView*)tableView {
    
}

@end
