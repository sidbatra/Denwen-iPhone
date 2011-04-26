//
//  DWUserViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWUserViewController.h"
#import "DWRequestsManager.h"
#import "DWGUIManager.h"
#import "DWMemoryPool.h"
#import "DWSession.h"
#import "DWFollowedPlacesViewController.h"
#import "DWProfilePicViewController.h"
#import "DWImageViewController.h"

//Cells
#import "DWItemFeedCell.h"
#import "DWMessageCell.h"

static NSInteger const kMessageCellIndex					= 2;
static NSString* const kImgPullToRefreshBackground			= @"userprofilefade.png";
static float	 const kPullToRefreshBackgroundRedValue		= 0.6156;
static float	 const kPullToRefreshBackgroundGreenValue	= 0.6666;
static float	 const kPullToRefreshBackgroundBlueValue	= 0.7372;
static float	 const kPullToRefreshBackgroundAlphaValue	= 1.0;
static NSInteger const kNewItemRowInTableView				= 0;
static NSString* const kMsgCurrentUserNoItems				= @"Everything you post shows up here";
static NSString* const kUserViewCellIdentifier				= @"UserViewCell";
static NSInteger const kActionSheetCancelIndex				= 2;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWUserViewController

@synthesize user                    = _user;
@synthesize userTitleView           = _userTitleView;
@synthesize smallProfilePicView     = _smallProfilePicView;

//----------------------------------------------------------------------------------------------------
- (id)initWithUser:(DWUser*)theUser 
	   andDelegate:(id)delegate {
	
	self = [super initWithDelegate:delegate];
	
	if (self) {
		
		self.user		= theUser;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemParsed:) 
													 name:kNNewItemParsed 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLoaded:) 
													 name:kNUserLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userError:) 
													 name:kNUserError
												   object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallUserImageLoaded:) 
													 name:kNImgSmallUserLoaded
												   object:nil];          
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav-Bar Methods
//----------------------------------------------------------------------------------------------------
- (void)setSmallUserImage:(UIImage*)smallUserImage {
    [self.smallProfilePicView setProfilePicButtonBackgroundImage:smallUserImage];
}

//----------------------------------------------------------------------------------------------------
- (void)updateUserTitleView {
    [self.userTitleView showUserStateFor:[self.user fullName] 
                       andFollowingCount:[self.user followingCount]];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapSmallUserImage:(id)sender event:(id)event {
    DWProfilePicViewController *profilePicViewController = [[DWProfilePicViewController alloc] 
                                                            initWithUser:self.user 
                                                             andDelegate:_delegate];
    
    [self.navigationController pushViewController:profilePicViewController 
                                         animated:YES];
    [profilePicViewController release];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    self.navigationItem.rightBarButtonItem  = nil;
    self.navigationItem.titleView           = nil;
                
	if(!_isLoadedOnce)
		[self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
	[super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.user.smallPreviewImage     = nil;
	self.user						= nil;
    self.userTitleView              = nil;
    self.smallProfilePicView        = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)loadItems {
	[super loadItems];	
	[[DWRequestsManager sharedDWRequestsManager] getUserWithID:self.user.databaseID
														atPage:_currentPage];
}

//----------------------------------------------------------------------------------------------------
- (void)userSelectedForItemID:(NSInteger)itemID {
    /**
     * Override to prevent recursion
     */
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)smallUserImageLoaded:(NSNotification*)notification {
	NSDictionary *info	= [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
    [self setSmallUserImage:[info objectForKey:kKeyImage]];
}

//----------------------------------------------------------------------------------------------------
- (void)newItemParsed:(NSNotification*)notification {
	DWItem *item = (DWItem*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyItem];
		
	if(_isLoadedOnce && self.user == item.user)
		[self addNewItem:item atIndex:kNewItemRowInTableView];
}

//----------------------------------------------------------------------------------------------------
- (void)userLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
		
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		NSDictionary *body	= [info objectForKey:kKeyBody];
		NSArray *items		= [body objectForKey:kKeyItems];
		
		[self.itemManager populateItems:items
							 withBuffer:NO
							  withClear:_isReloading];
		
		[self.user update:[body objectForKey:kKeyUser]];
        [self.user startSmallPreviewDownload];
        
        if (self.user.smallPreviewImage) 
            [self setSmallUserImage:self.user.smallPreviewImage];

		_isLoadedOnce = YES;
		
		if([self.itemManager totalItems]==0 && [self.user isCurrentUser]) {
			self.messageCellText	= kMsgCurrentUserNoItems;
			_tableViewUsage			= kTableViewAsProfileMessage;
		}
		else
			_tableViewUsage = kTableViewAsData;			
	}
	
	[self finishedLoadingItems];	
	[self.tableView reloadData]; 
}

//----------------------------------------------------------------------------------------------------
- (void)userError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	[self finishedLoadingItems];
}	


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UserTitleViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)didTapTitleView {
    DWFollowedPlacesViewController *followedView = [[DWFollowedPlacesViewController alloc] 
                                                    initWithDelegate:_delegate
                                                            withUser:self.user];
    
    [self.navigationController pushViewController:followedView 
                                         animated:YES];
    [followedView release]; 
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)willShowOnNav {
    if (!self.userTitleView)
        self.userTitleView = [[[DWUserTitleView alloc] 
                               initWithFrame:CGRectMake(kNavTitleViewX, 0,
                                                        kNavTitleViewWidth,kNavTitleViewHeight) 
                                    delegate:self 
                                   titleMode:kNavTitleAndSubtitleMode 
                               andButtonType:kDWButtonTypeStatic] autorelease];
    
    [self.navigationController.navigationBar addSubview:self.userTitleView];
    
    if (!self.smallProfilePicView)
        self.smallProfilePicView = [[[DWSmallProfilePicView alloc] 
                                    initWithFrame:CGRectMake(260, 0, 
                                                             kNavTitleViewWidth,kNavTitleViewHeight) 
                                        andTarget:self] autorelease];
    
    [self.navigationController.navigationBar addSubview:self.smallProfilePicView];
    [self updateUserTitleView];
}

@end

