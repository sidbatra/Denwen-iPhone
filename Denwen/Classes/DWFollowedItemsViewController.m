//
//  DWFollowedItemsViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWFollowedItemsViewController.h"

//Declarations for private methods
//
@interface DWFollowedItemsViewController () 
@end


@implementation DWFollowedItemsViewController



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		self.view.hidden = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemCreated:) 
													 name:N_NEW_ITEM_CREATED 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newApplicationBadgeNumber:) 
													 name:N_NEW_APPLICATION_BADGE_NUMBER
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followedItemsRead:) 
													 name:N_FOLLOWED_ITEMS_READ
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemsLoaded:) 
													 name:kNFollowedItemsLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemsError:) 
													 name:kNFollowedItemsError
												   object:nil];
	}
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.refreshHeaderView applyBackgroundColor:[UIColor whiteColor]];	
	self.view.hidden = YES;
}


// Called when the controller becomes selected in the container
//
- (void)viewIsSelected {

	self.view.hidden = NO;
		

	//TODO: or if a lot of time has expired
	if(!_isLoadedOnce || [DWSession sharedDWSession].refreshFollowedItems) {
		
		if([self loadItems]) {
			
			_reloading = [DWSession sharedDWSession].refreshFollowedItems;
			
			// Remove any old messages in the UITableView
			_tableViewUsage = TABLE_VIEW_AS_SPINNER;
			[self.tableView reloadData];
			
			_isLoadedOnce = YES;
		}
	}
	
}


// Called when the controller is deselected from the container
//
- (void)viewIsDeselected {
	self.view.hidden = YES;
	[DWNotificationHelper followedItemsRead];
}


// Scrolls the table view to the first cell
//
- (void)scrollToTop {
	if(_isLoadedOnce && [self.tableView numberOfSections]) {
		NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}


#pragma mark -
#pragma mark UIScrollViewDelegate


// Override scrollViewDidEndDragging if the user isn't signed in
//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if([[DWSession sharedDWSession] isActive])
		[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}




#pragma mark -
#pragma mark ItemManager 

// Fetches recent items from places being followed by the current user
//
- (BOOL)loadItems {
	[super loadItems];
	
	BOOL status = NO;
		
	if([[DWSession sharedDWSession] isActive]) {
		
		if([DWSession sharedDWSession].refreshFollowedItems)
			[self resetPagination];
		
		[[DWRequestsManager sharedDWRequestsManager] getFollowedItemsAtPage:_currentPage];
				
		status = YES;
	}
	else {
		_tableViewUsage = TABLE_VIEW_AS_MESSAGE;
		self.messageCellText = FOLLOW_LOGGEDOUT_MSG;
		[self.tableView reloadData];
		
		[_refreshHeaderView refreshLastUpdatedDate];
	}
	
	return status;	
}




#pragma mark -
#pragma mark Notification handlers


// New item created
//
- (void)newItemCreated:(NSNotification*)notification {
	DWItem *item = (DWItem*)[notification object];
	
	if(_isLoadedOnce && item.fromFollowedPlace)
		[self addNewItem:item atIndex:0];
}


// Handle arrival of a new application badge number when the application resumes or starts
//
- (void)newApplicationBadgeNumber:(NSNotification*)notification {
	
	//Launch silent reload
	if(_isLoadedOnce && followedItemsUnreadCount) {
		
		if([(NSString*)[notification object] isEqualToString:BADGE_NOTIFICATION_BACKGROUND]) {
			_tableViewUsage = TABLE_VIEW_AS_SPINNER;
			[self.tableView reloadData];
		}
		
		[self resetPagination];
		_reloading = YES;
		[self loadItems];
	}
}


// Fired when followed items have been read by the user
//
- (void)followedItemsRead:(NSNotification*)notification {
	[self.tableView reloadData];
}


- (void)itemsLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary* body = [info objectForKey:kKeyBody];
		
		NSArray *items = [body objectForKey:ITEMS_JSON_KEY];
		[_itemManager populateItems:items withBuffer:NO withClear:_reloading];
		
		if(![_itemManager totalItems]){
			_tableViewUsage = TABLE_VIEW_AS_MESSAGE;
			self.messageCellText = kMsgNoFollowPlacesCurrentUser;
		}
		else
			_tableViewUsage = TABLE_VIEW_AS_DATA;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FOLLOWED_ITEMS_LOADED
															object:nil];
		
		[DWSession sharedDWSession].refreshFollowedItems = NO;
	}
	
	[self finishedLoadingItems];
	[self.tableView reloadData];
}		

- (void)itemsError:(NSNotification*)notification {
	[self finishedLoadingItems];
}






#pragma mark -
#pragma mark Table view data source


// Override cellForRowAtIndexPath to highlight new items if any
//
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:theTableView cellForRowAtIndexPath:indexPath];
	
	if([cell isKindOfClass:[DWItemFeedCell class]] && indexPath.row < followedItemsUnreadCount)
		[(DWItemFeedCell*)cell displayNewCellState];
		
	
	return cell;
}



#pragma mark -
#pragma mark Memory management

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
    [super dealloc];
}

@end

