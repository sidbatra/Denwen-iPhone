//
//  DWAppDelegate.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWAppDelegate.h"
#import "ASIDownloadCache.h"
#import "DWItemsContainerViewController.h"
#import "DWUserContainerViewController.h"
#import "DWPlacesContainerViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"
#import "DWSession.h"
#import "DWNotificationsHelper.h"
#import "NSString+Helpers.h"

static NSString* const kFacebookURLPrefix			= @"fb";
static NSInteger const kLocationRefreshDistance		= 750;
static NSString* const kMsgLowMemoryWarning			= @"Low memory warning recived, memory pool free memmory called";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWAppDelegate

@synthesize window				= _window;
@synthesize signupToolbar		= _signupToolbar;

@synthesize tabBarController	= _tabBarController;
@synthesize placesTabButton		= _placesTabButton;
@synthesize feedTabButton		= _feedTabButton;

@synthesize locationManager		= _locationManager;

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
- (void)createTabBarController {
	/**
	 * Increase height of the signupToolbar to fully cover the tabBarController
	 */
	[self.signupToolbar setFrame:CGRectMake(0, 431, 320, 49)];
	
	
	DWItemsContainerViewController *itemsContainerViewController = [[DWItemsContainerViewController alloc] init];
	UINavigationController *itemsNavController = [[UINavigationController alloc] initWithRootViewController:itemsContainerViewController];
	[itemsContainerViewController release];
	
	
	/*DWUserContainerViewController *userContainerViewController = [[DWUserContainerViewController alloc] init];
	 UINavigationController *userNavController = [[UINavigationController alloc] initWithRootViewController:userContainerViewController];
	 [userContainerViewController release];
	 */															
	
	
	DWPlacesContainerViewController *placesContainerViewController = [[DWPlacesContainerViewController alloc] init];
	UINavigationController *placesNavController = [[UINavigationController alloc] initWithRootViewController:placesContainerViewController];
	[placesContainerViewController release];
	
	
	
	NSMutableArray *localControllersArray = [[NSMutableArray alloc] initWithCapacity:3];
	[localControllersArray addObject:placesNavController];
	//[localControllersArray addObject:userNavController];
	[localControllersArray addObject:itemsNavController];
	
	[itemsNavController release];
	//[userNavController release];
	[placesNavController release];
	
	
	self.tabBarController					= [[UITabBarController alloc] init];
	self.tabBarController.delegate			= self;
	self.tabBarController.viewControllers	= localControllersArray;
	[localControllersArray release];
	
	
	[self.window addSubview:self.tabBarController.view];
	[self.window makeKeyAndVisible];
	
	
	self.locationManager					= [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate			= self;
	self.locationManager.desiredAccuracy	= kCLLocationAccuracyBest;
	self.locationManager.distanceFilter		= kLocationRefreshDistance;	
	
	
	[[DWSession sharedDWSession] isActive] ? [self displaySignedInState] : [self displaySignedOutState];
	
	
	
	/*self.placesTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [self.placesTabButton setFrame:CGRectMake(0,0,kSegmentedPlacesViewWidth/2,49)];
	 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:@"popular_on.png"] forState:UIControlStateNormal];
	 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:@"popular_on.png"] forState:UIControlStateHighlighted];
	 [self.placesTabButton addTarget:self action:@selector(didTapPlacesButton:event:) forControlEvents:UIControlEventTouchUpInside];
	 [tabBarController.tabBar addSubview:self.placesTabButton];
	 
	 self.feedTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [self.feedTabButton setFrame:CGRectMake(kSegmentedPlacesViewWidth/2,0,kSegmentedPlacesViewWidth/2,49)];
	 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:@"nearby_off.png"] forState:UIControlStateNormal];
	 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:@"nearby_off.png"] forState:UIControlStateHighlighted];
	 [self.feedTabButton addTarget:self action:@selector(didTapFeedButton:event:) forControlEvents:UIControlEventTouchUpInside];
	 [tabBarController.tabBar addSubview:self.feedTabButton];
	 */
}

/*
 - (void)didTapPlacesButton:(id)sender event:(id)event {
 NSLog(@"Selected index - %d",tabBarController.selectedIndex);
 
 if(tabBarController.selectedIndex == 0) {
 NSLog(@"popping");
 [(UINavigationController*)tabBarController.selectedViewController popToRootViewControllerAnimated:YES];
 }
 else {
 tabBarController.selectedIndex = 0;
 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:@"popular_on.png"] forState:UIControlStateNormal];
 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:@"popular_on.png"] forState:UIControlStateHighlighted];
 
 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:@"nearby_off.png"] forState:UIControlStateNormal];
 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:@"nearby_off.png"] forState:UIControlStateHighlighted];
 }
 }
 
 - (void)didTapFeedButton:(id)sender event:(id)event {
 
 if(tabBarController.selectedIndex == 1) {
 [(UINavigationController*)tabBarController.selectedViewController popToRootViewControllerAnimated:YES];
 }
 else {
 tabBarController.selectedIndex = 1;
 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:@"popular_off.png"] forState:UIControlStateNormal];
 [self.placesTabButton setBackgroundImage:[UIImage imageNamed:@"popular_off.png"] forState:UIControlStateHighlighted];
 
 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:@"nearby_on.png"] forState:UIControlStateNormal];
 [self.feedTabButton setBackgroundImage:[UIImage imageNamed:@"nearby_on.png"] forState:UIControlStateHighlighted];
 }
 
 }
 */

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
	[[DWRequestsManager sharedDWRequestsManager] createVisit];
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
		[self createTabBarController];
	
	[self.locationManager startUpdatingLocation];
		
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
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
		
	//if(![[UIApplication sharedApplication] enabledRemoteNotificationTypes])
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
	
	[[DWRequestsManager sharedDWRequestsManager] createVisit];
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
#pragma mark Location related methods


//----------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	[DWSession sharedDWSession].location = newLocation;
	
	if(!_isVisitRecorded) {
		_isVisitRecorded = YES;
		[[DWRequestsManager sharedDWRequestsManager] createVisit];
	}
	
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

@end
