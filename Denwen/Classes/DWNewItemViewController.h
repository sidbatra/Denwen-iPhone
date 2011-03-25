//
//  DWNewItemViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWRequestManager.h"
#import "DWS3Uploader.h"
#import "MBProgressHUD.h"
#import "DWItem.h"
#import "DWSessionManager.h"
#import "NSString+Helpers.h"
#import "DWMemoryPool.h"
#import "DWImageHelper.h"
#import "DWVideoHelper.h"
#import "KTTextView.h"

@protocol DWNewItemViewControllerDelegate;

@interface DWNewItemViewController : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,DWS3UploaderDelegate,DWRequestManagerDelegate> {
	
	KTTextView *textView;
	UILabel *placeLabel;
	UIButton *imagePickerButton;
	UINavigationItem *navItem;
	UIImageView *imagePreview;
	UILabel *imagePlaceholder;
	
	MBProgressHUD *mbProgressIndicator;
	
	NSString *_placeName;
	NSString *_filename;
	NSString *_itemData;
	NSInteger _placeID;	
	
	BOOL _isUploading;
	BOOL _postInitiated;
	BOOL _forcePost;
	BOOL _isLoadedOnce;
	
	DWS3Uploader *_s3Uploader;
	DWRequestManager *_requestManager;
	
	id <DWNewItemViewControllerDelegate> _delegate;
}

@property (nonatomic, retain) IBOutlet KTTextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *placeLabel;
@property (nonatomic, retain) IBOutlet UIButton *imagePickerButton;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet UIImageView *imagePreview;
@property (nonatomic, retain) IBOutlet UILabel *imagePlaceholder;


@property (copy) NSString *placeName;
@property (copy) NSString *filename;


- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)postButtonClicked:(id)sender;
- (IBAction)selectPhotoButtonClicked:(id)sender;


- (id)initWithDelegate:(id)delegate withPlaceName:(NSString*)placeName withPlaceID:(int)placeID withForcePost:(bool)forcePost;


@end

@protocol DWNewItemViewControllerDelegate
- (void)newItemCreationFinished;
- (void)newItemCancelled;
@end

