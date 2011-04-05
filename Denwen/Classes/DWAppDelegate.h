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
	UIButton			*_feedTabButton;
	
	CLLocationManager	*_locationManager;
}

/**
 * Used tp obtain current location of the device
 */
@property (nonatomic,retain) CLLocationManager *locationManager;

/**
 * UI Properties
 */

@property (nonatomic,retain) UIButton *placesTabButton;
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

