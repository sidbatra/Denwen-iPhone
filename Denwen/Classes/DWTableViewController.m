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
							 withBackgroundColor:[UIColor blackColor]];
    
	
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
- (void)loadData {
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows {
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)totalRows {
    /**
     * Override in the child class to get the total number of rows in the table
     */
    return 0;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)dataCellHeight {
    /**
    * Override in the child class to get the height of the data cells
    */
    return 0;
}

//----------------------------------------------------------------------------------------------------
- (void)loadNextPage {
	_prePaginationCellCount = [self totalRows];
	_currentPage++;
    _isLoadingPage = YES;
	
	[self loadData];
}

//----------------------------------------------------------------------------------------------------
- (void)finishedLoading {
	[self.refreshHeaderView refreshLastUpdatedDate];
	
	if([self totalRows] < _rowsPerPage || 
	   ([self totalRows] - _prePaginationCellCount < _rowsPerPage &&
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
		rows = [self  totalRows] + _paginationCellStatus;
	else
		rows = kTVLoadingCellCount;
    
	return rows;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CGFloat height = 0;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [self totalRows])
		height = [self dataCellHeight];
	
	else if(_tableViewUsage == kTableViewAsData && indexPath.row == [self totalRows])
		height = kPaginationCellHeight;
	else
		height = kTVLoadingCellHeight;
	
	return height;
}


//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(_tableViewUsage == kTableViewAsData && indexPath.row == [self totalRows]) {
		
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
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTVDefaultCellIdentifier];
		
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
    [self loadData];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _isReloading; 
}

//----------------------------------------------------------------------------------------------------
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return nil;
}


@end
