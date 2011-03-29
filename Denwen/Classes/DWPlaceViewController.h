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
#import "DWRequestsManager.h"
#import "DWPlaceCell.h"
#import "MBProgressHUD.h"
#import "DWPlaceDetailsViewController.h"
#import "DWShareViewController.h"
#import "DWSession.h"


@interface DWPlaceViewController : DWItemFeedViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	DWPlace *_origPlace;
	DWPlace *_place;
	DWFollowing *_following;

	MBProgressHUD *mbProgressIndicator;
	
	BOOL _newItemPrompt;
	BOOL _isViewLoaded;
	BOOL _isReadyForCreateItem;
	NSInteger _uploadID;
	
	NSDictionary *_placeJSON;
}

@property (retain) DWFollowing *following;
@property (retain) NSDictionary *placeJSON;

-(id)initWithPlace:(DWPlace*)place withNewItemPrompt:(BOOL)newItemPrompt andDelegate:(id)delegate;


@end
