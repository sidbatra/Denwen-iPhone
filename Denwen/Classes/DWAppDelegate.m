//
//  DWAppDelegate.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWAppDelegate.h"
#import "ASIDownloadCache.h"
#import "DWItemsContainerViewController.h"
#import "DWUserContainerViewController.h"
#import "DWPlacesContainerViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"
#import "DWSession.h"
#import "DWMemoryPool.h"
#import "DWNotificationsHelper.h"
#import "NSString+Helpers.h"


@interface DWAppDelegate () 
- (void)createTabBarController;
- (void)displaySignedInState;
- (void)displaySignedOutState;

- (void)createVisit;
@end


@implementation DWAppDelegate

@synthesize window,signupToolbar;



#pragma mark -
#pragma mark Application lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	//[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	
	[DWMemoryPool initPool];
	
	[[DWSession sharedDWSession] read];

	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userLogsIn:) 
												 name:N_USER_LOGS_IN
											   object:nil];
	
	
	//launchURL = (NSURL*)[launchOptions valueForKey:@"UIApplicationLaunchOptionsURLKey"];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


// Free non essential resources when the app enters the background
//
- (void)applicationDidEnterBackground:(UIApplication *)application {
	[DWMemoryPool freeMemory];
}


// Create a new visit when the app is about to come into the foreground
//
- (void)applicationWillEnterForeground:(UIApplication *)application {
	[self createVisit];
}


// Fired when a remote notification is received when the app is open
//
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[[DWNotificationsHelper sharedDWNotificationsHelper] handleLiveNotificationWithUserInfo:userInfo];
}


// A URL matching one of the custom schemes is opened
//
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

	if([[url absoluteString] hasPrefix:FACEBOOK_URL_PREFIX]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FACEBOOK_URL_OPENED 
															object:url];	
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_DENWEN_URL_OPENED 
															object:[url absoluteString]];	
	}
	
	return YES;
}


// Listens for the application launching for the first time or coming out of the background
// 
- (void)applicationDidBecomeActive:(UIApplication *)application {

	// If first launch
	if(tabBarController == nil) 
		[self createTabBarController];
	
	[_locationManager startUpdatingLocation];
		
	[[DWNotificationsHelper sharedDWNotificationsHelper] handleBackgroundNotification];
}


- (void)applicationWillTerminate:(UIApplication *)application {
}



// Release any prior memory usuage by navController and init 
// and add a fresh copy onto the stack.
//
- (void)createTabBarController {
	//Increase height of the signupToolbar to fully cover the tabBarController
	[signupToolbar setFrame:CGRectMake(0, 431, 320, 49)];
	
	
	DWItemsContainerViewController *itemsContainerViewController = [[DWItemsContainerViewController alloc] init];
	UINavigationController *itemsNavController = [[UINavigationController alloc] 
												  initWithRootViewController:itemsContainerViewController];
	[itemsContainerViewController release];
	
	
	
	
	/*DWUserContainerViewController *userContainerViewController = [[DWUserContainerViewController alloc] init];
	UINavigationController *userNavController = [[UINavigationController alloc] 
												  initWithRootViewController:userContainerViewController];
	[userContainerViewController release];
	*/															
	
	
	
	
	DWPlacesContainerViewController *placesContainerViewController = [[DWPlacesContainerViewController alloc] init];
	UINavigationController *placesNavController = [[UINavigationController alloc] 
												   initWithRootViewController:placesContainerViewController];
	[placesContainerViewController release];
	 
	
	
	NSMutableArray *localControllersArray = [[NSMutableArray alloc] initWithCapacity:3];
	[localControllersArray addObject:placesNavController];
	//[localControllersArray addObject:userNavController];
	[localControllersArray addObject:itemsNavController];
	
	
	
	[itemsNavController release];
	//[userNavController release];
	[placesNavController release];
	
	
	tabBarController = [[UITabBarController alloc] init];
	tabBarController.delegate = self;
	tabBarController.viewControllers = localControllersArray;
	[localControllersArray release];
	
	
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.distanceFilter = LOCATION_REFRESH_DISTANCE;	
	
	if(![[DWSession sharedDWSession] isActive]) 
		[self displaySignedOutState];
	else
		[self displaySignedInState];
}


// Changes the UI to display a signed in state
//
- (void)displaySignedInState {
	tabBarController.tabBar.hidden = NO;
	signupToolbar.hidden = YES;
	[window bringSubviewToFront:tabBarController.view];
}

// Changes the UI to display a signed out state
//
- (void)displaySignedOutState {
	tabBarController.tabBar.hidden = YES;
	signupToolbar.hidden = NO;
	[window bringSubviewToFront:signupToolbar];	
}


// Creates a visit for the current user
//
- (void)createVisit {
	if([[DWSession sharedDWSession] isActive])
		[[DWRequestsManager sharedDWRequestsManager] createVisit];
}



#pragma mark -
#pragma mark Notifications

// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
		
	//if(![[UIApplication sharedApplication] enabledRemoteNotificationTypes])
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
	
	[self createVisit];
}	


#pragma mark -
#pragma mark Push notificatin delegate methods


// User approves push notifications
//
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[DWRequestsManager sharedDWRequestsManager] updateDeviceIDForCurrentUser:[NSString stringWithFormat:@"%@",deviceToken]];
}


// User rejects push noitifications
//
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}



#pragma mark -
#pragma mark IB Events

// User clicks the signup button
//
- (void)signupButtonClicked:(id)sender {
	DWSignupViewController *signupView = [[DWSignupViewController alloc] initWithDelegate:self];
	[tabBarController presentModalViewController:signupView animated:YES];
	[signupView release];
}

// User clicks the login button
//
- (void)loginButtonClicked:(id)sender {
	DWLoginViewController *loginView = [[DWLoginViewController alloc] initWithDelegate:self];
	[tabBarController presentModalViewController:loginView animated:YES];
	[loginView release];
}

	

#pragma mark -
#pragma mark Login delegate methods

// User cancels the login process
//
- (void)loginViewCancelButtonClicked {
	[tabBarController dismissModalViewControllerAnimated:YES];
}

// User successfully logs in
//
-  (void)loginSuccessful {
	[self displaySignedInState];
	[tabBarController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark Signup delegate methods


//Hide the signup toolbar when the signup view appears
//
- (void)signupViewLoaded {
	signupToolbar.hidden = YES;
}

// User cancels the signup process
//
- (void)signupViewCancelButtonClicked {
	signupToolbar.hidden = NO;
	[tabBarController dismissModalViewControllerAnimated:YES];
}

// User successfully signs up
//
- (void)signupSuccessful {
	[self displaySignedInState];
	[tabBarController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark Location related methods


// Receives location updates from the locationManager
//
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	
	[DWSession sharedDWSession].location = newLocation;
	
	if(!_isVisitRecorded) {
		_isVisitRecorded = YES;
		[self createVisit];
	}
	
	//NSLog(@"%f %f %f T %f ",
	// newLocation.coordinate.latitude,
	// newLocation.coordinate.longitude,
	// newLocation.horizontalAccuracy,
	// fabs([newLocation.timestamp timeIntervalSinceNow])
	// );
	//[[NSNotificationCenter defaultCenter] postNotificationName:N_LOCATION_CHANGED object:newLocation];
}


// Receives error messages from the locationManager
//
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	//TODO: handle location procurement error
	/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"There was an error estimating your location"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];*/
}




#pragma mark -
#pragma mark UITabBarControllerDelegate

// Fired when the selected item changes
//
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNTabSelectionChanged
														object:nil
													  userInfo:nil];
}

// Fired when the user clicks on a tab bar item to change the tab
//
- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController {
	return YES;
}



#pragma mark -
#pragma mark Memory management

// The usual memory warning
//
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"memory warning received and images purged");
	[DWMemoryPool freeMemory];
}


// The usual memory cleanup
//
- (void)dealloc {
	[_locationManager release];
	[tabBarController release];
	
	[signupToolbar release];
    [window release];
	
    [super dealloc];
}


@end
