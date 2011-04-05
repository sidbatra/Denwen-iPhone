//
//  DWPlaceViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceViewController.h"
#import "DWPlaceDetailsViewController.h"
#import "DWShareViewController.h"
#import "DWRequestsManager.h"
#import "DWPlaceCell.h"
#import "DWItemFeedCell.h"
#import "DWSession.h"

static NSInteger const kNewItemRowInTableView				= 1;
static NSString* const kPlaceViewCellIdentifier				= @"PlaceViewCell";
static NSString* const kImgPullToRefreshBackground			= @"refreshfade.png";
static NSString* const kMsgActionSheetCancel				= @"Cancel";
static NSString* const kMsgActionSheetUnfollow				= @"Unfollow";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceViewController

@synthesize place				= _place;
@synthesize following			= _following;
@synthesize mbProgressIndicator	= _mbProgressIndicator;

//----------------------------------------------------------------------------------------------------
-(id)initWithPlace:(DWPlace*)thePlace
	   andDelegate:(id)delegate {
	
	self = [super initWithDelegate:delegate];
	
	if (self) {
		
		self.place			= thePlace;
		_tableViewUsage		= kTableViewAsData;
			
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(largePlaceImageLoaded:) 
													 name:kNImgLargePlaceLoaded
												   object:nil];
	
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
	
	self.place.largePreviewImage	= nil;
	self.place						= nil;
	self.following					= nil;
	self.mbProgressIndicator		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)updateTitle {
	self.title = [self.place titleText];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:kGenericBackButtonTitle
																			  style:UIBarButtonItemStyleBordered
																			 target:nil
																			 action:nil] autorelease];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																							target:self 
																							action:@selector(didPressCreateNewItem:event:)]
											  autorelease];
	
	self.mbProgressIndicator = [[[MBProgressHUD alloc] initWithView:self.navigationController.view] autorelease];
	[self.navigationController.view addSubview:self.mbProgressIndicator];
	
	[self updateTitle];
	
	if(!_isLoadedOnce)
		[self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
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
	self.mbProgressIndicator.labelText = @"Following";
	[self.mbProgressIndicator showUsingAnimation:YES];
	
	[[DWRequestsManager sharedDWRequestsManager] createFollowing:self.place.databaseID];
}

//----------------------------------------------------------------------------------------------------
- (void)sendUnfollowRequest {
	self.mbProgressIndicator.labelText = @"Unfollowing";
	[self.mbProgressIndicator showUsingAnimation:YES];
	
	[[DWRequestsManager sharedDWRequestsManager] destroyFollowing:self.following.databaseID
													ofPlaceWithID:self.place.databaseID];
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
		
		[self.itemManager populateItems:[body objectForKey:kKeyItems]
							 withBuffer:_currentPage==kPagInitialPage
							  withClear:_isReloading];
		
		[self.place update:[body objectForKey:kKeyPlace]];

		[self updateFollowing:[body objectForKey:kKeyFollowing]];
		
		[self updateTitle];
		
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
		
		NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 
														 inSection:0];
		
		DWPlaceCell *placeCell = (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
		
		[self updateFollowing:[[info objectForKey:kKeyBody] objectForKey:kKeyFollowing]];
		[placeCell displayFollowingState];
		[self.place updateFollowerCount:1];
		
		[self updateTitle];
	}
	
	[self.mbProgressIndicator hideUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)followingDestroyed:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 
														 inSection:0];
		
		DWPlaceCell *placeCell = (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
		
		self.following = nil;
		[placeCell displayUnfollowingState];
		[self.place updateFollowerCount:-1];
		
		[self updateTitle];
	}
	
	[self.mbProgressIndicator hideUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)followingError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	[self.mbProgressIndicator hideUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)largePlaceImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData)
		return;
	
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.place.databaseID)
		return;
	
	
	UIImage *image = [info objectForKey:kKeyImage];
	
	NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 
													 inSection:0];
	
	DWPlaceCell *cell				= (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
	cell.placeBackgroundImage.image = image;
	
	[self.refreshHeaderView applyBackgroundImage:image 
								   withFadeImage:[UIImage imageNamed:kImgPullToRefreshBackground]
							 withBackgroundColor:[UIColor blackColor]];
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
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row==0)
		height = kPlaceViewCellHeight;
	else
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];

	return height;
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row == 0) {
		DWPlaceCell *cell = (DWPlaceCell*)[tableView dequeueReusableCellWithIdentifier:kPlaceViewCellIdentifier];
		
		if (!cell) {
			cell = [[[DWPlaceCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:kPlaceViewCellIdentifier
											   withRow:indexPath.row 
											  andTaget:self] autorelease];
		}
		
		if(self.following)
			[cell displayFollowingState];
		else
			[cell displayUnfollowingState];
		
			
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.placeName.text = self.place.name;
		
		[self.place startLargePreviewDownload];
		
		if(self.place.largePreviewImage)
			cell.placeBackgroundImage.image = self.place.largePreviewImage;
		else
			cell.placeBackgroundImage.image = [UIImage imageNamed:kImgGenericPlaceHolder];
		
		return cell;
	}
	else {
		cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
		
		if(_tableViewUsage == kTableViewAsData && indexPath.row < [self.itemManager totalItems])
			[(DWItemFeedCell*)cell disablePlaceButtons];
	}
	
	return cell;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(_tableViewUsage == kTableViewAsData && indexPath.row == 0) {
		
		DWPlaceDetailsViewController *placeDetailsViewController = [[DWPlaceDetailsViewController alloc] 
																	initWithPlace:self.place];
		placeDetailsViewController.hidesBottomBarWhenPushed = YES;
		
		[self.navigationController pushViewController:placeDetailsViewController 
											 animated:YES];
		[placeDetailsViewController release];
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLick events from across the view

//----------------------------------------------------------------------------------------------------
- (void)didPressCreateNewItem:(id)sender event:(id)event {
}

//----------------------------------------------------------------------------------------------------
- (void)didTapPlaceName:(id)sender event:(id)event {
	/**
	 * Override clicks on Place Name to prevent recursive navigation
	 */
}

//----------------------------------------------------------------------------------------------------
- (void)didTapPlaceImage:(id)sender event:(id)event {
	/**
	 * Override clicks on Place Name to prevent recursive navigation
	 */
}

//----------------------------------------------------------------------------------------------------
- (void)didTapFollowButton:(id)sender event:(id)event {
	[self sendFollowRequest];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapUnfollowButton:(id)sender event:(id)event {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:kMsgActionSheetCancel
											   destructiveButtonTitle:kMsgActionSheetUnfollow
													otherButtonTitles:nil];
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}

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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	if (buttonIndex == 0)
		[self sendUnfollowRequest];
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

@end

