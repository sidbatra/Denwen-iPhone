//
//  DWFollowedPlacesViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlaceListViewController.h"
#import "DWUser.h"

/**
 * Display places followed by a user
 */
@interface DWFollowedPlacesViewController : DWPlaceListViewController {
	DWUser *_user;
}

/**
 * User whose places are being displayed
 */
@property (nonatomic,retain) DWUser* user;

/**
 * Init with delegate to receive events when a place is selected and the
 * user whose places are being displayed
 */
- (id)initWithDelegate:(id)delegate 
			  withUser:(DWUser*)user;
	
@end
