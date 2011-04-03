//
//  DWItemsContainerViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemsContainerViewController.h"
#import "DWNotificationsHelper.h"
#import "DWSession.h"

static NSString* const kTabTitle		= @"Feed";
static NSString* const kImgTab			= @"posts.png";
static NSString* const kMsgUnload		= @"Unload called on items container";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemsContainerViewController


//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if (self) {		
		self.title				= kTabTitle;
		self.tabBarItem.image	= [UIImage imageNamed:kImgTab];
		
		
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
		
		if (&UIApplicationDidEnterBackgroundNotification != NULL) {
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationEnteringBackground:) 
														 name:UIApplicationDidEnterBackgroundNotification
													   object:nil];
		}
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	/**
	 * Add subview
	 */
	if(!followedViewController)
		followedViewController = [[DWFollowedItemsViewController alloc] initWithDelegate:self];
	[self.view addSubview:followedViewController.view];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated {
	[self resetBadgeValue];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {	
	NSLog(@"%@",kMsgUnload);
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[followedViewController release];
    
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
	
	if([self isSelectedTab] && [DWNotificationsHelper sharedDWNotificationsHelper].unreadItems) {
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

@end
