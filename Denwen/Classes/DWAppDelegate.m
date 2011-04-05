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
#import "DWSession.h"
#import "DWNotificationsHelper.h"
#import "NSString+Helpers.h"

static NSString* const kFacebookURLPrefix			= @"fb";
static NSInteger const kLocationRefreshDistance		= 750;
static NSString* const kMsgLowMemoryWarning			= @"Low memory warning recived, memory pool free memmory called";
static NSInteger const kTabBarWidth					= 320;
static NSInteger const kTabBarHeight				= 49;
static NSInteger const kPlacesIndex					= 0;
static NSInteger const kCreateIndex					= 1;
static NSInteger const kFeedIndex					= 2;
static NSString* const kImgPlacesOn					= @"popular_on.png";
static NSString* const kImgPlacesOff				= @"popular_off.png";
static NSString* const kImgCreateOn					= @"popular_on.png";
static NSString* const kImgCreateOff				= @"popular_off.png";
static NSString* const kImgFeedOn					= @"popular_on.png";
static NSString* const kImgFeedOff					= @"popular_off.png";


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
		
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userLogsIn:) 
												 name:kNUserLogsIn
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
	
	DWCreateViewController *createViewController = [[DWCreateViewController alloc] init];
	
	DWPlacesContainerViewController *placesContainerViewController = [[DWPlacesContainerViewController alloc] init];
	UINavigationController *placesNavController = [[UINavigationController alloc] initWithRootViewController:placesContainerViewController];
	[placesContainerViewController release];
	
	
	NSMutableArray *localControllersArray = [[NSMutableArray alloc] initWithCapacity:3];
	[localControllersArray addObject:placesNavController];
	[localControllersArray addObject:createViewController];
	[localControllersArray addObject:itemsNavController];
	
	[itemsNavController release];
	[createViewController release];
	[placesNavController release];
	
	
	self.tabBarController					= [[UITabBarController alloc] init];
	self.tabBarController.delegate			= self;
	self.tabBarController.viewControllers	= localControllersArray;
	[localControllersArray release];	
	
	_currentSelectedTabIndex = kPlacesIndex;
}

//----------------------------------------------------------------------------------------------------
- (void)setupCustomTabBar {
	/**
	 * Create places tab button
	 */
	 self.placesTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [self.placesTabButton setFrame:CGRectMake(0,0,kTabBarWidth/3,kTabBarHeight)];
	
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
	[self.createTabButton setFrame:CGRectMake(kTabBarWidth/3,0,kTabBarWidth/3,kTabBarHeight)];
	
	[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOff] 
								  forState:UIControlStateNormal];
	
	[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOff] 
								  forState:UIControlStateHighlighted];
	
	[self.createTabButton addTarget:self action:@selector(customTabBarSelectionChanged:) 
				 forControlEvents:UIControlEventTouchUpInside];
	
	[self.tabBarController.tabBar addSubview:self.createTabButton];
	
	
	/**
	 * Create feed tab button
	 */	
	 self.feedTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [self.feedTabButton setFrame:CGRectMake((kTabBarWidth/3) * 2,0,kTabBarWidth/3,kTabBarHeight)];
	
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

// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
		
	//if(![[UIApplication sharedApplication] enabledRemoteNotificationTypes])
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
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
#pragma mark Private

//----------------------------------------------------------------------------------------------------
- (void)hidePreviouslySelectedTab {
	if(_currentSelectedTabIndex == kPlacesIndex) {
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOff] 
										forState:UIControlStateNormal];
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOff] 
										forState:UIControlStateHighlighted];
	}
	else if(_currentSelectedTabIndex == kCreateIndex) {
		
		[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOff] 
										forState:UIControlStateNormal];
		
		[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOff] 
										forState:UIControlStateHighlighted];
	}
	else if(_currentSelectedTabIndex == kFeedIndex) {
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOff] 
										forState:UIControlStateNormal];
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOff] 
										forState:UIControlStateHighlighted];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadSelectedTab {	
	if(_currentSelectedTabIndex == kPlacesIndex) {
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOn] 
										forState:UIControlStateNormal];
		
		[self.placesTabButton setBackgroundImage:[UIImage imageNamed:kImgPlacesOn] 
										forState:UIControlStateHighlighted];
	}
	else if(_currentSelectedTabIndex == kCreateIndex) {
		
		[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOn] 
										forState:UIControlStateNormal];
		
		[self.createTabButton setBackgroundImage:[UIImage imageNamed:kImgCreateOn] 
										forState:UIControlStateHighlighted];
	}
	else if(_currentSelectedTabIndex == kFeedIndex) {
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOn] 
									  forState:UIControlStateNormal];
		
		[self.feedTabButton setBackgroundImage:[UIImage imageNamed:kImgFeedOn] 
									  forState:UIControlStateHighlighted];
	}
	
	self.tabBarController.selectedIndex = _currentSelectedTabIndex;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIControlEventValueChanged

//----------------------------------------------------------------------------------------------------
- (void)customTabBarSelectionChanged:(id)sender {
	
	NSInteger newSelection = -1;
	
	if(self.placesTabButton == (UIButton*)sender)
		newSelection = kPlacesIndex;
	else if(self.createTabButton == (UIButton*)sender)
		newSelection = kCreateIndex;
	else if(self.feedTabButton == (UIButton*)sender)
		newSelection = kFeedIndex;
	
	if(_currentSelectedTabIndex != newSelection) {
		[self hidePreviouslySelectedTab];
		_currentSelectedTabIndex = newSelection;
		[self loadSelectedTab];
	}
	else if(_currentSelectedTabIndex == kPlacesIndex) {
		[(UINavigationController*)self.tabBarController.selectedViewController popToRootViewControllerAnimated:YES];
	}
	else if(_currentSelectedTabIndex == kCreateIndex) {
	}
	else if(_currentSelectedTabIndex == kFeedIndex) {
		[(UINavigationController*)self.tabBarController.selectedViewController popToRootViewControllerAnimated:YES];
	}
}


@end
