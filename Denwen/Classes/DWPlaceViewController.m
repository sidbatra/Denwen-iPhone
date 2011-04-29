//
//  DWPlaceViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceViewController.h"
#import "DWPlaceDetailsViewController.h"
#import "DWShareViewController.h"
#import "DWRequestsManager.h"
#import "DWGUIManager.h"
#import "DWPlaceCell.h"
#import "DWItemFeedCell.h"
#import "DWSession.h"
#import "DWConstants.h"

static NSInteger const kNewItemRowInTableView				= 0;
static NSString* const kPlaceViewCellIdentifier				= @"PlaceViewCell";
static NSString* const kImgPullToRefreshBackground			= @"refreshfade.png";
static NSString* const kMsgActionSheetCancel				= @"Cancel";
static NSString* const kMsgActionSheetUnfollow				= @"Unfollow";
static NSInteger const kTagUnfollowActionSheet              = -1;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceViewController

@synthesize place                   = _place;
@synthesize following               = _following;
@synthesize placeTitleView          = _placeTitleView;


//----------------------------------------------------------------------------------------------------
-(id)initWithPlace:(DWPlace*)thePlace
	   andDelegate:(id)delegate {
	
	self = [super initWithDelegate:delegate];
	
	if (self) {
		
		self.place = thePlace;
	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemParsed:) 
													 name:kNNewItemParsed 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeLoaded:) 
													 name:kNPlaceLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeError:) 
													 name:kNPlaceError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingCreated:) 
													 name:kNNewFollowingCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingError:)
													 name:kNNewFollowingError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingDestroyed:) 
													 name:kNFollowingDestroyed
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingError:)
													 name:kNFollowingDestroyError
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.place						= nil;
	self.following					= nil;
    self.placeTitleView             = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)updatePlaceTitleView {
    if (self.following) 
        [self.placeTitleView showFollowedStateFor:self.place.name 
                                andFollowingCount:[self.place followersCount]];
    else
        [self.placeTitleView showUnfollowedStateFor:self.place.name 
                                  andFollowingCount:[self.place followersCount]];    
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    self.navigationItem.rightBarButtonItem  = [DWGUIManager placeDetailsButton:self];
    self.navigationItem.titleView           = nil;
    
    if (!self.placeTitleView)
        self.placeTitleView = [[[DWPlaceTitleView alloc] 
                                initWithFrame:CGRectMake(kNavTitleViewX, 0,
                                                         kNavTitleViewWidth,kNavTitleViewHeight) 
                                delegate:self 
                                titleMode:kNavTitleAndSubtitleMode 
                                andButtonType:kDWButtonTypeDynamic] autorelease];
        			
	if(!_isLoadedOnce)
		[self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)updateFollowing:(NSDictionary*)followJSON {
	
	if(![followJSON isKindOfClass:[NSNull class]] && [followJSON count]) {
		self.following = [[[DWFollowing alloc] init] autorelease];
		[self.following populate:followJSON];
	}
	else {
		self.following = nil;
	}

}

//----------------------------------------------------------------------------------------------------
- (void)loadItems {
	[super loadItems];
	
	[[DWRequestsManager sharedDWRequestsManager] getPlaceWithHashedID:self.place.hashedID
													   withDatabaseID:self.place.databaseID
															   atPage:_currentPage];
}

//----------------------------------------------------------------------------------------------------
- (void)sendFollowRequest {
	[[DWRequestsManager sharedDWRequestsManager] createFollowing:self.place.databaseID];
}

//----------------------------------------------------------------------------------------------------
- (void)sendUnfollowRequest {
	[[DWRequestsManager sharedDWRequestsManager] destroyFollowing:self.following.databaseID
													ofPlaceWithID:self.place.databaseID];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[DWItemFeedCell class]])
        [(DWItemFeedCell*)cell setPlaceButtonAsDisabled]; 
    
    return cell;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)placeLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary *body = [info objectForKey:kKeyBody];
	
        [self.place update:[body objectForKey:kKeyPlace]];

		[self.itemManager populateItems:[body objectForKey:kKeyItems]
							 withBuffer:NO
							  withClear:_isReloading];
    
		[self updateFollowing:[body objectForKey:kKeyFollowing]];
		
		[self updatePlaceTitleView];
		
		_tableViewUsage = kTableViewAsData;			
		_isLoadedOnce	= YES;
	}
	
	[self finishedLoadingItems];
	[self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------
- (void)placeError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	[self finishedLoadingItems];
}

//----------------------------------------------------------------------------------------------------
- (void)followingCreated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		[self updateFollowing:[info objectForKey:kKeyBody]];
		[self.place updateFollowerCount:1];
        
		[self updatePlaceTitleView];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)followingDestroyed:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		self.following = nil;
		[self.place updateFollowerCount:-1];   
		
		[self updatePlaceTitleView];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)followingError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
}

//----------------------------------------------------------------------------------------------------
- (void)newItemParsed:(NSNotification*)notification {
	DWItem *item = (DWItem*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyItem];
	
	if(_isLoadedOnce && self.place == item.place) {
		[self addNewItem:item
				 atIndex:kNewItemRowInTableView];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLick events from across the view

//----------------------------------------------------------------------------------------------------
- (void)didTapShareButton:(id)sender event:(id)event {
	DWShareViewController *shareView	= [[DWShareViewController alloc] initWithPlace:self.place
																		   andDelegate:self];
	shareView.modalTransitionStyle		= UIModalTransitionStyleFlipHorizontal;	
	
    [self.navigationController presentModalViewController:shareView 
												 animated:YES];
	
	[shareView release];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapPlaceDetailsButton:(id)sender event:(id)event {
    DWPlaceDetailsViewController *placeDetailsViewController = [[DWPlaceDetailsViewController alloc] 
                                                                initWithPlace:self.place
                                                                  andDelegate:_delegate];
    
    [self.navigationController pushViewController:placeDetailsViewController 
                                         animated:YES];
    
    [placeDetailsViewController release];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark PlaceTitleViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)didTapTitleView {
    if (self.following) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                 delegate:self 
                                                        cancelButtonTitle:kMsgActionSheetCancel
                                                   destructiveButtonTitle:kMsgActionSheetUnfollow
                                                        otherButtonTitles:nil];
        actionSheet.tag  = kTagUnfollowActionSheet;
        [actionSheet showInView:[_delegate requestCustomTabBarController].view];
        [actionSheet release];    
    }
    else {
        [self.placeTitleView showProcessingState];
        [self sendFollowRequest];
    }
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIActionSheet Delegate
//----------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	if (buttonIndex == 0 && actionSheet.tag == kTagUnfollowActionSheet) {
        [self.placeTitleView showProcessingState];
		[self sendUnfollowRequest];
    }
    else
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ShareViewControllerDelegate

//----------------------------------------------------------------------------------------------------
-(void)shareViewCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)shareViewFinished:(NSString*)data 
				   sentTo:(NSInteger)sentTo {
	
	[self.navigationController dismissModalViewControllerAnimated:YES];

	[[DWRequestsManager sharedDWRequestsManager] createShareForPlaceWithID:self.place.databaseID 
																  withData:data 
																	sentTo:sentTo];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)willShowOnNav {
    [self.navigationController.navigationBar addSubview:self.placeTitleView];  
}

@end

