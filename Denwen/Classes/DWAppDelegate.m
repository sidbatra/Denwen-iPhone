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
#import "DWPlacesCache.h"
#import "DWRequestsManager.h"
#import "DWMemoryPool.h"
#import "DWSession.h"
#import "DWNotificationsHelper.h"
#import "NSString+Helpers.h"

static NSString* const kFacebookURLPrefix			= @"fb";
static NSInteger const kLocationRefreshDistance		= 500;
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
static NSString* const kMsgLocErrorTitle            = @"Location Needed";
static NSString* const kMsgLocError                 = @"To use Denwen, turn on location in your iPhone settings.";
static NSString* const kMsgCustomButtonTitle        = @"OK";


 
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWAppDelegate

@synthesize window				= _window;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(newFeedItemsLoaded:) 
												 name:kNNewFeedItemsLoaded
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(newFeedItemsRead:) 
												 name:kNNewFeedItemsRead
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
	
	
	
	self.tabBarController.subControllers    = [NSArray arrayWithObjects:
                                               self.placesNavController,
                                               [[[UIViewController alloc] init] autorelease],
                                               self.itemsNavController,nil];
	
	[self.window addSubview:self.tabBarController.view];
	
	
	((DWPlacesContainerViewController*)self.placesNavController.topViewController).customTabBarController	= self.tabBarController;
	((DWItemsContainerViewController*)self.itemsNavController.topViewController).customTabBarController		= self.tabBarController;
}

//----------------------------------------------------------------------------------------------------
- (void)setupApplication {	
	[self setupTabBarController];	
	
	[self.window addSubview:self.tabBarController.view];
	[self.window makeKeyAndVisible];
	
	
	[self setupLocationTracking];
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
- (void)newFeedItemsLoaded:(NSNotification*)notification {
    [self.tabBarController highlightTabAtIndex:kTabBarFeedIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)newFeedItemsRead:(NSNotification*)notification {
    [self.tabBarController dimTabAtIndex:kTabBarFeedIndex];
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
    
    if([error code] == kCLErrorDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgLocErrorTitle
														message:kMsgLocError
													   delegate:self
											  cancelButtonTitle:kMsgCustomButtonTitle
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
    }        
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIAlertViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    exit(0);
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
