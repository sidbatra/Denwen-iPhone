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
#import "DWUserTitleView.h"
#import "DWSmallProfilePicView.h"
#import "DWUser.h"
#import "DWItemFeedCell.h"

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
@synthesize profilePicManager       = _profilePicManager;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userFollowingCountUpdated:) 
													 name:kNUserFollowingCountUpdated
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userProfilePicUpdated:) 
													 name:kNUserProfilePicUpdated
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
                       andFollowingCount:self.user.followingCount];
    
    if (self.user.hasPhoto || [self.user isCurrentUser]) 
        [self.smallProfilePicView enableProfilePicButton];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapSmallUserImage:(id)sender event:(id)event {
    if (self.user.hasPhoto) {
        DWProfilePicViewController *profilePicViewController = [[DWProfilePicViewController alloc] 
                                                                initWithUser:self.user 
                                                                 andDelegate:_delegate];
    
        [self.navigationController pushViewController:profilePicViewController animated:YES];
        [profilePicViewController release]; 
    }
    else if([self.user isCurrentUser]) {
        
        if(!self.profilePicManager)
            self.profilePicManager = [[[DWProfilePicManager alloc] initWithDelegate:self] autorelease];
    
        [self.profilePicManager presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
    }
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
    
    if (!self.userTitleView)
        self.userTitleView = [[[DWUserTitleView alloc] 
                               initWithFrame:CGRectMake(kNavTitleViewX,
                                                        0,
                                                        kNavTitleViewWidth,
                                                        kNavTitleViewHeight) 
                                    delegate:self 
                                   titleMode:kNavTitleAndSubtitleMode 
                               andButtonType:kDWButtonTypeStatic] autorelease];
    
    
    if (!self.smallProfilePicView)
        self.smallProfilePicView = [[[DWSmallProfilePicView alloc] 
                                     initWithFrame:CGRectMake(260,
                                                              0, 
                                                              kNavTitleViewWidth,
                                                              kNavTitleViewHeight) 
                                         andTarget:self] autorelease];
                
	if(!_isLoadedOnce)
		[_dataSourceDelegate loadData];
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
    self.profilePicManager          = nil;
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[DWItemFeedCell class]])
        [(DWItemFeedCell*)cell setUserButtonAsDisabled]; 
    
    return cell;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (void)loadData {
    [[DWRequestsManager sharedDWRequestsManager] getUserWithID:self.user.databaseID
                                                fromLastItemID:_lastID];
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
        
        [self.user update:[body objectForKey:kKeyUser]];

		[self.itemManager populateItems:items
							 withBuffer:NO
							  withClear:_isReloading];
		                
        [self updateUserTitleView];
        
        if (!self.user.smallPreviewImage) 
            [self.user startSmallPreviewDownload];
        else
            [self setSmallUserImage:self.user.smallPreviewImage];

		_isLoadedOnce = YES;
		
		if([self.itemManager totalItems]==0 && [self.user isCurrentUser]) {
			self.messageCellText	= kMsgCurrentUserNoItems;
			_tableViewUsage			= kTableViewAsProfileMessage;
		}
		else
			_tableViewUsage = kTableViewAsData;			
	}
	
	[self finishedLoading];	
	[self.tableView reloadData]; 
}

//----------------------------------------------------------------------------------------------------
- (void)userError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	[self finishedLoadingWithError];
}	

//----------------------------------------------------------------------------------------------------
- (void)userFollowingCountUpdated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
    [self updateUserTitleView];
}	

//----------------------------------------------------------------------------------------------------
- (void)userProfilePicUpdated:(NSNotification*)notification {    
    if(![self.user isCurrentUser])
		return;
    
    [self.smallProfilePicView showNormalState];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWProfilePicManagerDelegate
//----------------------------------------------------------------------------------------------------
- (UIViewController*)requestController {
    return [_delegate requestCustomTabBarController];
}

//----------------------------------------------------------------------------------------------------
- (void)photoPicked {
    [self.smallProfilePicView showProcessingState];
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
    [self.navigationController.navigationBar addSubview:self.userTitleView];
    [self.navigationController.navigationBar addSubview:self.smallProfilePicView];
}

@end

