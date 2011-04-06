//
//  DWAppDelegate.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/**
 * Application delegate
 */
@interface DWAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate> {
    UIWindow			*_window;
	UIToolbar			*_signupToolbar;
	
	UITabBarController	*_tabBarController;
	UIButton			*_placesTabButton;
	UIButton			*_createTabButton;
	UIButton			*_feedTabButton;
	
	CLLocationManager	*_locationManager;
	
	NSInteger			_currentSelectedTabIndex;
}

/**
 * Used tp obtain current location of the device
 */
@property (nonatomic,retain) CLLocationManager *locationManager;

/**
 * UI Properties
 */

@property (nonatomic,retain) UIButton *placesTabButton;
@property (nonatomic,retain) UIButton *createTabButton;
@property (nonatomic,retain) UIButton *feedTabButton;
@property (nonatomic,retain) UITabBarController *tabBarController;

/**
 * IBOutlet properties
 */

@property (nonatomic,retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) IBOutlet UIToolbar *signupToolbar;


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

