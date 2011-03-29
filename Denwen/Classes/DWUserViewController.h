//
//  DWUserViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWImageViewController.h"
#import "DWSelectPlaceViewController.h"
#import "DWNewItemViewController.h"
#import "DWNewPlaceViewController.h"
#import "DWPlaceViewController.h"
#import "DWFollowedPlacesViewController.h"
#import "DWUser.h"
#import "DWRequestsManager.h"
#import "MBProgressHUD.h"
#import "DWSession.h"
#import "DWUserCell.h"


@interface DWUserViewController : DWItemFeedViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	DWUser *_user;
	
	UIViewController *uiShell;
	MBProgressHUD *mbProgressIndicator;
	
	int _userID;
	BOOL _isCurrenUserProfile;
	BOOL _isCurrentUser;
	NSInteger _uploadID;
}

- (id)initWithUserID:(int)userID andDelegate:(id)delegate;
- (id)initWithUserID:(int)userID hideBackButton:(BOOL)hideBackButton andDelegate:(id)delegate;

@end
