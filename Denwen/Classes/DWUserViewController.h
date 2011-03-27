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
#import "DWRequestManager.h"
#import "DWS3Uploader.h"
#import "MBProgressHUD.h"
#import "DWSession.h"
#import "DWUserCell.h"


@interface DWUserViewController : DWItemFeedViewController<DWS3UploaderDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	DWUser *_user;
	DWRequestManager *_updateUserRequestManager;
	DWS3Uploader *_s3Uploader;
	
	UIViewController *uiShell;
	MBProgressHUD *mbProgressIndicator;
	
	int _userID;
	BOOL _isCurrenUserProfile;
	BOOL _isCurrentUser;
}

- (id)initWithUserID:(int)userID andDelegate:(id)delegate;
- (id)initWithUserID:(int)userID hideBackButton:(BOOL)hideBackButton andDelegate:(id)delegate;

@end
