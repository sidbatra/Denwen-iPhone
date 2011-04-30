//
//  DWAppDelegate.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWAppDelegate.h"
#import "ASIDownloadCache.h"
#import "DWTabBarController.h"
#import "DWItemsContainerViewController.h"
#import "DWCreateViewController.h"
#import "DWPlacesContainerViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"
#import "DWPlacesCache.h"
#import "DWSession.h"
#import "DWNotificationsHelper.h"
#import "NSString+Helpers.h"

#define kNavBarColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

static NSString* const kFacebookURLPrefix			= @"fb";
static NSInteger const kLocationRefreshDistance		= 750;
static NSInteger const kLocationFreshnessThreshold	= 10;
static NSString* const kMsgLowMemoryWarning			= @"Low memory warning recived, memory pool free memory called";
static NSInteger const kTabBarWidth					= 320;
static NSInteger const kTabBarHeight				= 49;
static NSInteger const kTabBarCount					= 2;
static NSString* const kImgPlacesOn					= @"tab_places_on.png";
static NSString* const kImgPlacesOff				= @"tab_places_off.png";
static NSString* const kImgCreateOn					= @"tab_create_active.png";
static NSString* const kImgCreateOff				= @"tab_create_on.png";
static NSString* const kImgFeedOn					= @"tab_feed_on.png";
static NSString* const kImgFeedOff					= @"tab_feed_off.png";


 
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWAppDelegate

@synthesize window				= _window;
@synthesize signupToolbar		= _signupToolbar;
@synthesize placesNavController	= _placesNavController;
@synthesize itemsNavController	= _itemsNavController;

@synthesize tabBarController	= _tabBarController;

@synthesize locationManager		= _locationManager;

//----------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {    
    
	//[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	
	[DWPlacesCache sharedDWPlacesCache];
    
    [DWNotificationsHelper sharedDWNotificationsHelper].backgroundRemoteInfo = [launchOptions objectForKey:
                                                                                    UIApplicationLaunchOptionsRemoteNotificationKey];
		
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
	
	self.window					= nil;
	self.signupToolbar			= nil;
	self.placesNavController	= nil;
	self.itemsNavController		= nil;
	
	self.tabBarController		= nil;
	
	self.locationManager		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	
	[[DWMemoryPool sharedDWMemoryPool] freeMemory];
	NSLog(@"%@",kMsgLowMemoryWarning);
}

//----------------------------------------------------------------------------------------------------
- (void)displaySignedInState {
	//self.tabBarController.tabBar.hidden	= NO;
	self.signupToolbar.hidden			= YES;
	[self.window bringSubviewToFront:self.tabBarController.view];
}

//----------------------------------------------------------------------------------------------------
- (void)displaySignedOutState {
	//self.tabBarController.tabBar.hidden	= YES;
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
    
    BOOL isLoggedIn     = [[DWSession sharedDWSession] isActive];
	
	NSArray *tabBarInfo	= [NSArray arrayWithObjects:
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:114]				,kKeyWidth,
							[NSNumber numberWithBool:!isLoggedIn]		,kKeyIsSelected,
							[NSNumber numberWithInt:kTabBarNormalTag]	,kKeyTag,
							kImgPlacesOn								,kKeySelectedImageName,
							kImgPlacesOff								,kKeyNormalImageName,
							nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:92]					,kKeyWidth,
							[NSNumber numberWithBool:NO]				,kKeyIsSelected,
							[NSNumber numberWithInt:kTabBarSpecialTag]	,kKeyTag,
							kImgCreateOff								,kKeySelectedImageName,
							kImgCreateOn								,kKeyHighlightedImageName,
							kImgCreateOff								,kKeyNormalImageName,
							nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:114]				,kKeyWidth,
							[NSNumber numberWithBool:isLoggedIn]		,kKeyIsSelected,
							[NSNumber numberWithInt:kTabBarNormalTag]	,kKeyTag,
							kImgFeedOn									,kKeySelectedImageName,
							kImgFeedOff									,kKeyNormalImageName,
							nil],
						   nil];
	
	self.tabBarController					= [[[DWTabBarController alloc] initWithDelegate:self 
																			withTabBarFrame:CGRectMake(0,411,kTabBarWidth,kTabBarHeight)
																			  andTabBarInfo:tabBarInfo] autorelease];
	
	
	
	self.tabBarController.subControllers = [NSArray arrayWithObjects:
											self.placesNavController,
											[[[UIViewController alloc] init] autorelease],
											self.itemsNavController,nil];
	
	[self.window addSubview:self.tabBarController.view];
	
	
	((DWPlacesContainerViewController*)self.placesNavController.topViewController).customTabBarController	= self.tabBarController;
	((DWItemsContainerViewController*)self.itemsNavController.topViewController).customTabBarController		= self.tabBarController;
}

//----------------------------------------------------------------------------------------------------
- (void)setupApplication {
	/**
	 * Increase height of the signupToolbar to fully cover the tabBarController
	 */
	[self.signupToolbar setFrame:CGRectMake(0, 431, kTabBarWidth, kTabBarHeight)];
	
	[self setupTabBarController];	
	
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


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
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
	
	if(fabs([newLocation.timestamp timeIntervalSinceNow]) < kLocationFreshnessThreshold) {
		
		[DWSession sharedDWSession].location = newLocation;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNNewLocationAvailable 
															object:nil];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTabBarControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)selectedTabModifiedFrom:(NSInteger)oldSelectedIndex 
							 to:(NSInteger)newSelectedIndex {
		
	if(newSelectedIndex == kTabBarCreateIndex) {
		DWCreateViewController *createView	= [[[DWCreateViewController alloc] init] autorelease];
		[self.tabBarController presentModalViewController:createView animated:NO];
	}
}

@end
