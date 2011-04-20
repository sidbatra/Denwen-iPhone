//
//  DWAppDelegate.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class DWTabBarController;

/**
 * Application delegate
 */
@interface DWAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate> {
    UIWindow				*_window;
	UIToolbar				*_signupToolbar;
	
	DWTabBarController		*_tabBarController;
	
	CLLocationManager		*_locationManager;
	
	UINavigationController	*_placesNavController;
	UINavigationController	*_itemsNavController;
}

/**
 * Used tp obtain current location of the device
 */
@property (nonatomic,retain) CLLocationManager *locationManager;

/**
 * UI Properties
 */

@property (nonatomic,retain) DWTabBarController *tabBarController;

/**
 * IBOutlet properties
 */

@property (nonatomic,retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) IBOutlet UIToolbar *signupToolbar;
@property (nonatomic,retain) IBOutlet UINavigationController *placesNavController;
@property (nonatomic,retain) IBOutlet UINavigationController *itemsNavController;


/**
 * IBAction events
 */

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)signupButtonClicked:(id)sender;

@end

/**
 * Declarations for select private methods
 */
@interface DWAppDelegate(Private)

/**
 * Init and position the UI elements that form the foundation
 * of the application. Also start services like location tracking
 */
- (void)setupApplication;

/**
 * Switches tabs to dispay the given tab index or 
 * pops controllers on an existing tab
 */
- (void)displayNewTab:(NSInteger)newTabIndex;
@end

