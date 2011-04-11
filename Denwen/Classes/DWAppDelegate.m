//
//  DWAppDelegate.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWAppDelegate.h"
#import "ASIDownloadCache.h"
#import "DWItemsContainerViewController.h"
#import "DWCreateViewController.h"
#import "DWPlacesContainerViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"
#import "DWPlacesCache.h"
#import "DWSession.h"
#import "DWNotificationsHelper.h"
#import "NSString+Helpers.h"

static NSString* const kFacebookURLPrefix			= @"fb";
static NSInteger const kLocationRefreshDistance		= 750;
static NSString* const kMsgLowMemoryWarning			= @"Low memory warning recived, memory pool free memory called";
static NSInteger const kTabBarWidth					= 320;
static NSInteger const kTabBarHeight				= 49;
static NSInteger const kTabBarCount					= 2;
static NSString* const kImgPlacesOn					= @"tab_places_on.png";
static NSString* const kImgPlacesOff				= @"tab_places_off.png";
static NSString* const kImgCreateOn					= @"tab_create_on.png";
static NSString* const kImgCreateOff				= @"tab_create_on.png";
static NSString* const kImgFeedOn					= @"tab_feed_on.png";
static NSString* const kImgFeedOff					= @"tab_feed_off.png";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWAppDelegate

@synthesize window				= _window;
@synthesize signupToolbar		= _signupToolbar;

@synthesize tabBarController	= _tabBarController;
@synthesize placesTabButton		= _placesTabButton;
@synthesize createTabButton		= _createTabButton;
@synthesize feedTabButton		= _feedTabButton;

@synthesize locationManager		= _locationManager;

//----------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {    
    
	//[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	
	[DWPlacesCache sharedDWPlacesCache];
		
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userLogsIn:) 
												 name:kNUserLogsIn
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(requestTabBarIndexChange:) 
												 name:kNRequestTabBarIndexChange
											   object:nil];
	
	//launchURL = (NSURL*)[launchOptions valueForKey:@"UIApplicationLaunchOptionsURLKey"];

    return YES;
}

//----------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application {
}

//----------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application {
	/**
	 * Free non critical resources when app enters background
	 */
	[[DWMemoryPool sharedDWMemoryPool] freeMemory];
}

//----------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application {
}

//----------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[[DWNotificationsHelper sharedDWNotificationsHelper] handleLiveNotificationWithUserInfo:userInfo];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

	if([[url absoluteString] hasPrefix:kFacebookURLPrefix]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNFacebookURLOpened 
															object:url];	
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNDenwenURLOpened 
															object:[url absoluteString]];	
	}
	
	return YES;
}

//----------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application {

	if(self.tabBarController == nil) 
		[self setupApplication];
			
	[[DWNotificationsHelper sharedDWNotificationsHelper] handleBackgroundNotification];
}

//----------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application {
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.window				= nil;
	self.signupToolbar		= nil;
	
	self.tabBarController	= nil;
	self.placesTabButton	= nil;
	self.createTabButton	= nil;
	self.feedTabButton		= nil;
	
	self.locationManager	= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	
	[[DWMemoryPool sharedDWMemoryPool] freeMemory];
	NSLog(@"%@",kMsgLowMemoryWarning);
}

//----------------------------------------------------------------------------------------------------
- (void)displaySignedInState {
	self.tabBarController.tabBar.hidden	= NO;
	self.signupToolbar.hidden			= YES;
	[self.window bringSubviewToFront:self.tabBarController.view];
}

//----------------------------------------------------------------------------------------------------
- (void)displaySignedOutState {
	self.tabBarController.tabBar.hidden	= YES;
	self.signupToolbar.hidden			= NO;
	[self.window bringSubviewToFront:self.signupToolbar];	
}

//----------------------------------------------------------------------------------------------------
- (void)setupLocationTracking {
	self.locationManager					= [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate			= self;
	self.locationManager.desiredAccuracy	= kCLLocationAccuracyBest;
	self.locationManager.distanceFilter		= kLocationRefreshDistance;	
	
	[self.locationManager startUpdatingLocation];
}

//----------------------------------------------------------------------------------------------------
- (void)setupTabBarController {
	DWItemsContainerViewController *itemsContainerViewController = [[DWItemsContainerViewController alloc] init];
	UINavigationController *itemsNavController = [[UINavigationController alloc] initWithRootViewController:itemsContainerViewController];
	[itemsContainerViewController release];
	
	DWPlacesContainerViewController *placesContainerViewController = [[DWPlacesContainerViewController alloc] init];
	UINavigationController *placesNavController = [[UINavigationController alloc] initWithRootViewController:placesContainerViewController];
	[placesContainerViewController release];
	
	
	NSMutableArray *localControllersArray = [[NSMutableArray alloc] initWithCapacity:kTabBarCount];
	[localControllersArray addObject:placesNavController];
	[localControllersArray addObject:itemsNavController];
	
	[itemsNavController release];
	[placesNavController release];
	
	
	self.tabBarController					= [[UITabBarController alloc] init];
	self.tabBarController.delegate			= self;
	self.tabBarController.viewControllers	= localControllersArray;
	[localControllersArray release];	
	
	_currentSelectedTabIndex = kTabBarPlacesIndex;
}

//----------------------------------------------------------------------------------------------------
- (void)setupCustomTabBar {
	/**
	 * Create places tab button
	 */
	 self.placesTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [self.placesTabButton setFrame:CGRectMake(0,0,106,kTabBarHeight)];
	
	 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOn] 
									 forState:UIControlStateNormal];
	
	 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOn] 
									 forState:UIControlStateHighlighted];
	
	 [self.placesTabButton addTarget:self action:@selector(customTabBarSelectionChanged:) 
					forControlEvents:UIControlEventTouchUpInside];
	
	[self.tabBarController.tabBar addSubview:self.placesTabButton]; 
	
	
	/**
	 * Create create tab button
	 */
	self.createTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.createTabButton setFrame:CGRectMake(106,0,108,kTabBarHeight)];
	
	[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOff] 
								  forState:UIControlStateNormal];
	
	[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOff] 
								  forState:UIControlStateHighlighted];
	
	[self.createTabButton addTarget:self action:@selector(createButtonClicked:) 
				 forControlEvents:UIControlEventTouchUpInside];
	
	[self.tabBarController.tabBar addSubview:self.createTabButton];
	
	
	/**
	 * Create feed tab button
	 */	
	 self.feedTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [self.feedTabButton setFrame:CGRectMake(214,0,106,kTabBarHeight)];
	
	 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOff] 
								   forState:UIControlStateNormal];
	
	 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOff] 
								   forState:UIControlStateHighlighted];
	
	 [self.feedTabButton addTarget:self action:@selector(customTabBarSelectionChanged:) 
				  forControlEvents:UIControlEventTouchUpInside];
	 
	[self.tabBarController.tabBar addSubview:self.feedTabButton];
}

//----------------------------------------------------------------------------------------------------
- (void)setupApplication {
	/**
	 * Increase height of the signupToolbar to fully cover the tabBarController
	 */
	[self.signupToolbar setFrame:CGRectMake(0, 431, kTabBarWidth, kTabBarHeight)];
	
	[self setupTabBarController];	
	[self setupCustomTabBar];
	
	[self.window addSubview:self.tabBarController.view];
	[self.window makeKeyAndVisible];
	
	
	[self setupLocationTracking];
	
	[[DWSession sharedDWSession] isActive] ? [self displaySignedInState] : [self displaySignedOutState];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)userLogsIn:(NSNotification*)notification {

	//if(![[UIApplication sharedApplication] enabledRemoteNotificationTypes])
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
}	

//----------------------------------------------------------------------------------------------------
- (void)requestTabBarIndexChange:(NSNotification*)notification {
	[self displayNewTab:[[[notification userInfo] objectForKey:kKeyTabIndex] integerValue]];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Push Notifiation Permission Responses


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[DWRequestsManager sharedDWRequestsManager] updateDeviceIDForCurrentUser:[NSString stringWithFormat:@"%@",deviceToken]];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)signupButtonClicked:(id)sender {
	DWSignupViewController *signupView = [[DWSignupViewController alloc] initWithDelegate:self];
	[self.tabBarController presentModalViewController:signupView 
										animated:YES];
	[signupView release];
}

//----------------------------------------------------------------------------------------------------
- (void)loginButtonClicked:(id)sender {
	DWLoginViewController *loginView = [[DWLoginViewController alloc] initWithDelegate:self];
	[self.tabBarController presentModalViewController:loginView 
										animated:YES];
	[loginView release];
}

	

#pragma mark -
#pragma mark DWLoginViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)loginViewCancelButtonClicked {
	[self.tabBarController dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
-  (void)loginSuccessful {
	[self displaySignedInState];
	[self.tabBarController dismissModalViewControllerAnimated:YES];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWSignupViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)signupViewLoaded {
	self.signupToolbar.hidden = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)signupViewCancelButtonClicked {
	self.signupToolbar.hidden = NO;
	[self.tabBarController dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)signupSuccessful {
	[self displaySignedInState];
	[self.tabBarController dismissModalViewControllerAnimated:YES];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark CLLocationManagerDelegate


//----------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	[DWSession sharedDWSession].location = newLocation;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNNewLocationAvailable 
														object:nil];
}

//----------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITabBarControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNTabSelectionChanged
														object:nil
													  userInfo:nil];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController {
	return YES;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Tab Manipulation

//----------------------------------------------------------------------------------------------------
- (void)hidePreviouslySelectedTab {
	if(_currentSelectedTabIndex == kTabBarPlacesIndex) {
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOff] 
										forState:UIControlStateNormal];
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOff] 
										forState:UIControlStateHighlighted];
	}
	else if(_currentSelectedTabIndex == kTabBarFeedIndex) {
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOff] 
										forState:UIControlStateNormal];
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOff] 
										forState:UIControlStateHighlighted];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadSelectedTab {	
	if(_currentSelectedTabIndex == kTabBarPlacesIndex) {
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOn] 
										forState:UIControlStateNormal];
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOn] 
										forState:UIControlStateHighlighted];
	}
	else if(_currentSelectedTabIndex == kTabBarFeedIndex) {
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOn] 
									  forState:UIControlStateNormal];
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOn] 
									  forState:UIControlStateHighlighted];
	}
	
	self.tabBarController.selectedIndex = _currentSelectedTabIndex;
}

//----------------------------------------------------------------------------------------------------
- (void)displayNewTab:(NSInteger)newTabIndex {
	
	if(_currentSelectedTabIndex != newTabIndex) {
		[self hidePreviouslySelectedTab];
		
		_currentSelectedTabIndex = newTabIndex;
		
		[self loadSelectedTab];
	}
	else {
		[(UINavigationController*)self.tabBarController.selectedViewController popToRootViewControllerAnimated:YES];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIControlEventValueChanged

//----------------------------------------------------------------------------------------------------
- (void)customTabBarSelectionChanged:(id)sender {
	
	NSInteger newTabIndex = -1;
	
	if(self.placesTabButton == (UIButton*)sender)
		newTabIndex = kTabBarPlacesIndex;
	else if(self.feedTabButton == (UIButton*)sender)
		newTabIndex = kTabBarFeedIndex;
	
	[self displayNewTab:newTabIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)createButtonClicked:(id)sender {
	DWCreateViewController *createView	= [[DWCreateViewController alloc] init];
	createView.modalTransitionStyle		= UIModalTransitionStyleCrossDissolve;
	
	[(UINavigationController*)self.tabBarController.selectedViewController presentModalViewController:createView
																							 animated:NO];
	[createView release];
}

@end
