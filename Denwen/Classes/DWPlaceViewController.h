//
//  DWPlaceViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"
#import "DWNewItemViewController.h"
#import "DWImageViewController.h"
#import "DWPlace.h"
#import "DWFollowing.h"
#import "DWRequestManager.h"
#import "DWS3Uploader.h"
#import "DWPlaceCell.h"
#import "MBProgressHUD.h"
#import "DWPlaceDetailsViewController.h"
#import "DWShareViewController.h"


@interface DWPlaceViewController : DWItemFeedViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,DWS3UploaderDelegate> {
	DWPlace *_place;
	DWFollowing *_following;
	DWRequestManager *_followRequestManager;
	DWRequestManager *_updatePlaceRequestManager;
	DWS3Uploader *_s3Uploader;

	MBProgressHUD *mbProgressIndicator;

	BOOL _newItemPrompt;
	BOOL _isViewLoaded;
	BOOL _isReadyForCreateItem;
	
	NSString *_placeHashedID;
}

@property (copy) NSString *placeHashedID;
@property (retain) DWFollowing *following;


- (id)initWithPlaceID:(NSString*)placeHashedID withNewItemPrompt:(BOOL)newItemPrompt andDelegate:(id)delegate;

@end
