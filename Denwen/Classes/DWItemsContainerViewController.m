//
//  DWItemsContainerViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemsContainerViewController.h"
#import "DWNotificationsViewController.h"
#import "DWCreationQueue.h"
#import "DWPostProgressView.h"
#import "DWProfilePicViewController.h"
#import "DWNotificationsHelper.h"
#import "DWSession.h"

static NSString* const kTabTitle                = @"Feed";
static NSString* const kMsgUnload               = @"Unload called on items container";
static NSString* const kImgNotificationsButton  = @"button_notifications.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemsContainerViewController

@synthesize smallProfilePicView = _smallProfilePicView;

//----------------------------------------------------------------------------------------------------
- (void)awakeFromNib {
	[super awakeFromNib];
		
	self.title				= kTabTitle;	
	
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
	
	if (&UIApplicationDidEnterBackgroundNotification != NULL) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationEnteringBackground:) 
													 name:UIApplicationDidEnterBackgroundNotification
												   object:nil];
	}	
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	if(!postProgressView) {
		postProgressView			= [[DWPostProgressView alloc] initWithFrame:CGRectMake(0,0,200,42)];
		postProgressView.delegate	= self;
	}
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];    
    [button setBackgroundImage:[UIImage imageNamed:kImgNotificationsButton] 
                      forState:UIControlStateNormal];

	[button addTarget:self action:@selector(didTapNotificationsButton:) 
     forControlEvents:UIControlEventTouchUpInside];
    
	[button setFrame:CGRectMake(0,0,60,44)];
	
    self.navigationItem.leftBarButtonItem   = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
        			
	/**
	 * Add subview
	 */
	if(!followedViewController)
		followedViewController = [[DWFollowedItemsViewController alloc] initWithDelegate:self];
	[self.view addSubview:followedViewController.view];
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
    self.smallProfilePicView = nil;

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
		
		if(!self.navigationItem.titleView)
			self.navigationItem.titleView = postProgressView;
		
		[postProgressView updateDisplayWithTotalActive:totalActive
										   totalFailed:totalFailed
										 totalProgress:totalProgress];
	}
	else {
		self.navigationItem.titleView = nil;
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
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWPostProgressViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)deleteButtonPressed {
	self.navigationItem.titleView = nil;
	
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
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)willShowOnNav {    
    if (!self.smallProfilePicView)
        self.smallProfilePicView = [[[DWSmallProfilePicView alloc] 
                                     initWithFrame:CGRectMake(260, 0, 
                                                              kNavTitleViewWidth,kNavTitleViewHeight) 
                                     andTarget:self] autorelease];
    
    [self.navigationController.navigationBar addSubview:self.smallProfilePicView];
    
    if (![DWSession sharedDWSession].currentUser.smallPreviewImage)
        [[DWSession sharedDWSession].currentUser startSmallPreviewDownload];
    else
        [self setSmallUserImage:[DWSession sharedDWSession].currentUser.smallPreviewImage];
}

@end
