//
//  DWItemsContainerViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemsContainerViewController.h"
#import "DWNotificationsViewController.h"
#import "DWCreationQueue.h"
#import "DWPostProgressView.h"
#import "DWProfilePicViewController.h"
#import "DWFollowedPlacesViewController.h"
#import "DWNotificationsHelper.h"
#import "DWSession.h"

static NSString* const kTabTitle                = @"Feed";
static NSString* const kMsgUnload               = @"Unload called on items container";
static NSString* const kImgNotificationsButton  = @"button_notifications.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemsContainerViewController

@synthesize smallProfilePicView     = _smallProfilePicView;
@synthesize userTitleView           = _userTitleView;


//----------------------------------------------------------------------------------------------------
- (void)awakeFromNib {
	[super awakeFromNib];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(newApplicationBadge:) 
												 name:kNNewApplicationBadge
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(followedItemsLoaded:) 
												 name:kNFollowedItemsLoaded
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(tabSelectionChanged:) 
												 name:kNTabSelectionChanged
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(creationQueueUpdated:) 
												 name:kNCreationQueueUpdated
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(smallUserImageLoaded:) 
                                                 name:kNImgSmallUserLoaded
                                               object:nil];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(userFollowingCountUpdated:) 
                                                 name:kNUserFollowingCountUpdated
                                               object:nil];  
    
	
	if (&UIApplicationDidEnterBackgroundNotification != NULL) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationEnteringBackground:) 
													 name:UIApplicationDidEnterBackgroundNotification
												   object:nil];
	}	
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
- (void)didTapSmallUserImage:(id)sender event:(id)event {
    DWProfilePicViewController *profilePicViewController = [[DWProfilePicViewController alloc] 
                                                            initWithUser:[DWSession sharedDWSession].currentUser 
                                                            andDelegate:self];
    
    [self.navigationController pushViewController:profilePicViewController 
                                         animated:YES];
    [profilePicViewController release];
}

//----------------------------------------------------------------------------------------------------
- (void)updateUserTitleView {
    [self.userTitleView showUserStateFor:[DWSession sharedDWSession].currentUser.firstName
                       andFollowingCount:[DWSession sharedDWSession].currentUser.followingCount];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	if(!postProgressView) {
		postProgressView			= [[DWPostProgressView alloc] initWithFrame:CGRectMake(60,0,200,44)];
		postProgressView.delegate	= self;
	}
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];    
    [button setBackgroundImage:[UIImage imageNamed:kImgNotificationsButton] 
                      forState:UIControlStateNormal];

	[button addTarget:self action:@selector(didTapNotificationsButton:) 
     forControlEvents:UIControlEventTouchUpInside];
    
	[button setFrame:CGRectMake(0,0,55,44)];
    
    self.navigationItem.leftBarButtonItem   = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];

	if(!followedViewController)
		followedViewController = [[DWFollowedItemsViewController alloc] initWithDelegate:self];
	[self.view addSubview:followedViewController.view];
    
    
    if (!self.userTitleView)
        self.userTitleView = [[[DWUserTitleView alloc] 
                               initWithFrame:CGRectMake(kNavTitleViewX, 0,
                                                        kNavTitleViewWidth,kNavTitleViewHeight) 
                               delegate:self 
                               titleMode:kNavTitleAndSubtitleMode 
                               andButtonType:kDWButtonTypeStatic] autorelease];
    [self updateUserTitleView];
    
    if (!self.smallProfilePicView)
        self.smallProfilePicView = [[[DWSmallProfilePicView alloc] 
                                     initWithFrame:CGRectMake(260, 0, 
                                                              kNavTitleViewWidth,kNavTitleViewHeight) 
                                     andTarget:self] autorelease];
    
    if (![DWSession sharedDWSession].currentUser.smallPreviewImage)
        [[DWSession sharedDWSession].currentUser startSmallPreviewDownload];
    else
        [self setSmallUserImage:[DWSession sharedDWSession].currentUser.smallPreviewImage];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self resetBadgeValue];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {		
	NSLog(@"%@",kMsgUnload);
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.smallProfilePicView    = nil;
    self.userTitleView          = nil;

	[followedViewController release];
	[postProgressView release];
    
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------------------------------
- (void)updateBadgeValueOnTabItem {

	NSInteger unreadItems = [DWNotificationsHelper sharedDWNotificationsHelper].unreadItems;
	
	if(unreadItems)
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",unreadItems];
	else
		self.tabBarItem.badgeValue = nil;
}

//----------------------------------------------------------------------------------------------------
- (void)resetBadgeValue {
	self.tabBarItem.badgeValue = nil;
	[[DWNotificationsHelper sharedDWNotificationsHelper] resetUnreadCount];
	[followedViewController followedItemsRead];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)newApplicationBadge:(NSNotification*)notification {
	NSInteger notificationType = [[(NSDictionary*)[notification userInfo] objectForKey:kKeyNotificationType] integerValue];
	
	if(notificationType == kPNBackground || !followedViewController)
		[self updateBadgeValueOnTabItem];
}

//----------------------------------------------------------------------------------------------------
- (void)tabSelectionChanged:(NSNotification*)notification {
	
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeySelectedIndex] integerValue] == kTabBarFeedIndex && 
		[DWNotificationsHelper sharedDWNotificationsHelper].unreadItems) {
		
		[self.navigationController popToRootViewControllerAnimated:NO];
		[followedViewController scrollToTop];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)followedItemsLoaded:(NSNotification*)notification {
	[self updateBadgeValueOnTabItem];
}

//----------------------------------------------------------------------------------------------------
- (void)applicationEnteringBackground:(NSNotification *)aNotification {
	if([self isSelectedTab])
		[self resetBadgeValue];
}

//----------------------------------------------------------------------------------------------------
- (void)creationQueueUpdated:(NSNotification*)notification {
	NSDictionary *userInfo	= [notification userInfo];
	
	NSInteger totalActive	= [[userInfo objectForKey:kKeyTotalActive] integerValue];
	NSInteger totalFailed	= [[userInfo objectForKey:kKeyTotalFailed] integerValue];
	float totalProgress		= [[userInfo objectForKey:kKeyTotalProgress] floatValue];
	
	NSLog(@"ACTIVE - %d, FAILED - %d, PROGRESS - %f",totalActive,totalFailed,totalProgress);
	
	if(totalActive || totalFailed) {
		
        if(!_isProgressBarActive) {
            _isProgressBarActive = YES;
            [self.navigationController.navigationBar addSubview:postProgressView];
            [self.userTitleView removeFromSuperview];
        }
		
		[postProgressView updateDisplayWithTotalActive:totalActive
										   totalFailed:totalFailed
										 totalProgress:totalProgress];
	}
	else {
        if(_isProgressBarActive) {
            _isProgressBarActive = NO;
            [self.navigationController.navigationBar addSubview:self.userTitleView];
            [postProgressView removeFromSuperview];
        }        
	}
}

//----------------------------------------------------------------------------------------------------
- (void)smallUserImageLoaded:(NSNotification*)notification {
	NSDictionary *info	= [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != [DWSession sharedDWSession].currentUser.databaseID)
		return;
    
    [self setSmallUserImage:[info objectForKey:kKeyImage]];
}

//----------------------------------------------------------------------------------------------------
- (void)userFollowingCountUpdated:(NSNotification*)notification {
    [self updateUserTitleView];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWPostProgressViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)deleteButtonPressed {
	[[DWCreationQueue sharedDWCreationQueue] deleteRequests];
}

//----------------------------------------------------------------------------------------------------
- (void)retryButtonPressed {
	[[DWCreationQueue sharedDWCreationQueue] retryRequests];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITouchEvents
//----------------------------------------------------------------------------------------------------
- (void)didTapNotificationsButton:(UIButton*)button {
    DWNotificationsViewController *notificationsView = [[DWNotificationsViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:notificationsView animated:YES];
    [notificationsView release];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapTitleView {
    DWFollowedPlacesViewController *followedView = [[DWFollowedPlacesViewController alloc] 
                                                    initWithDelegate:self
                                                    withUser:[DWSession sharedDWSession].currentUser];
    
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
    
    if(_isProgressBarActive)
        [self.navigationController.navigationBar addSubview:postProgressView];
    else
        [self.navigationController.navigationBar addSubview:self.userTitleView];
    
    [self.navigationController.navigationBar addSubview:self.smallProfilePicView];
}

@end
