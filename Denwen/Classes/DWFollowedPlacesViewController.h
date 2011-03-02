//
//  DWFollowedPlacesViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlaceListViewController.h"
#import "DWSessionManager.h"

@interface DWFollowedPlacesViewController : DWPlaceListViewController {
	NSInteger _userID;
	BOOL _isCurrentUser;
	NSString *_titleText;
}

- (id)initWithDelegate:(id)delegate withUserName:(NSString*)userName andUserID:(NSInteger)userID;
	
@end
