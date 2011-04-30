//
//  DWFollowedItemsViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFollowedItemsViewController.h"
#import "DWItemFeedCell.h"
#import "DWNotificationsHelper.h"
#import "DWRequestsManager.h"
#import "DWSession.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFollowedItemsViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemParsed:) 
													 name:kNNewItemParsed 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newApplicationBadge:) 
													 name:kNNewApplicationBadge
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemsLoaded:) 
													 name:kNFollowedItemsLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemsError:) 
													 name:kNFollowedItemsError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingModified:) 
													 name:kNNewFollowingCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingModified:) 
													 name:kNFollowingDestroyed
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	 
	if(!_isLoadedOnce)
        [self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}


//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)scrollToTop {
	if(_isLoadedOnce && [self.tableView numberOfSections]) {

		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
							  atScrollPosition:UITableViewScrollPositionTop 
									  animated:YES];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadItems {
	[super loadItems];
	[[DWRequestsManager sharedDWRequestsManager] getFollowedItemsAtPage:_currentPage];
}

//----------------------------------------------------------------------------------------------------
- (void)loadNewItems {
    [self hardRefresh];
}

//----------------------------------------------------------------------------------------------------
- (void)followedItemsRead {
	[self.tableView reloadData];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)newItemParsed:(NSNotification*)notification {
	DWItem *item = (DWItem*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyItem];
	
	if(_isLoadedOnce)
		[self addNewItem:item atIndex:0];
}

//----------------------------------------------------------------------------------------------------
- (void)newApplicationBadge:(NSNotification*)notification {
	
	NSInteger notificationType = [[(NSDictionary*)[notification userInfo] objectForKey:kKeyNotificationType] integerValue];
	
	if(_isLoadedOnce && [DWNotificationsHelper sharedDWNotificationsHelper].unreadItems) {
		
		/**
		 * Perform a silent reload unless its a background push notification
		 */
		if(notificationType == kPNBackground) {
			_tableViewUsage = kTableViewAsSpinner;
			[self.tableView reloadData];
		}
		
		[self resetPagination];
		_isReloading = YES;
		[self loadItems];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)itemsLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *items = [[info objectForKey:kKeyBody] objectForKey:kKeyItems];
		[_itemManager populateItems:items withBuffer:NO withClear:_isReloading];
		
		if(![_itemManager totalItems]) {
			_tableViewUsage = kTableViewAsMessage;
			self.messageCellText = kMsgNoFollowPlacesCurrentUser;
		}
		else
			_tableViewUsage = kTableViewAsData;
		
		_isLoadedOnce = YES;
	}
	
	[self finishedLoadingItems];
	[self.tableView reloadData];
}		

//----------------------------------------------------------------------------------------------------
- (void)itemsError:(NSNotification*)notification {
	[self finishedLoadingItems];
}

//----------------------------------------------------------------------------------------------------
- (void)followingModified:(NSNotification*)notification {
	[self hardRefresh];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource


// Override cellForRowAtIndexPath to highlight new items if any
//
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:theTableView cellForRowAtIndexPath:indexPath];
	
	if([cell isKindOfClass:[DWItemFeedCell class]] && 
	   indexPath.row < [DWNotificationsHelper sharedDWNotificationsHelper].unreadItems) {
		
		//[(DWItemFeedCell*)cell displayNewCellState];
	}
		
	
	return cell;
}

@end

