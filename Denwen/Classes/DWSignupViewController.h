//
//  DWSignupViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWUser.h";
#import "DWRequestsManager.h"
#import "NSString+Helpers.h"
#import "DWSession.h"
#import "DWMemoryPool.h"
#import "UIImage+ImageProcessing.h"

#import "MBProgressHUD.h"

@protocol DWSignupViewControllerDelegate;

@interface DWSignupViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	
	UIView *signupFieldsContainerView;
	UITextField *fullNameTextField;
	UITextField *emailTextField;
	UITextField *passwordTextField;
	UIBarButtonItem *doneButton;
	UIButton *imagePickerButton;
											
	MBProgressHUD *mbProgressIndicator;
											
	NSString *_photoFilename;										
	NSString *_password;
	
	BOOL _isUploading;
	BOOL _signupInitiated;
	NSInteger _uploadID;
	
	
	id <DWSignupViewControllerDelegate> _delegate;
}

@property (nonatomic, retain) IBOutlet UIView *signupFieldsContainerView;
@property (nonatomic, retain) IBOutlet UITextField *fullNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *imagePickerButton;

@property (copy) NSString *photoFilename;
@property (copy) NSString *password;


- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)selectPhotoButtonClicked:(id)sender;

@end


@protocol DWSignupViewControllerDelegate
- (void)signupViewLoaded;
- (void)signupViewCancelButtonClicked;
- (void)signupSuccessful;
@end
