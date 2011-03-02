//
//  DWAppDelegate.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWItemsContainerViewController.h"
#import "DWUserContainerViewController.h"
#import "DWPlacesContainerViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"
#import "DWCache.h"
#import "DWSessionManager.h"
#import "DWMemoryPool.h"
#import "DWUserLocation.h"
#import "DWNotificationHelper.h"



@interface DWAppDelegate : NSObject <UIApplicationDelegate, UINavigationBarDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate,DWItemFeedViewControllerDelegate> {
    UIWindow *window;
	UIToolbar *signupToolbar;
	
	UITabBarController *tabBarController;
	
	CLLocationManager *_locationManager;
	
	BOOL _isVisitRecorded;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIToolbar *signupToolbar;

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)signupButtonClicked:(id)sender;

@end

