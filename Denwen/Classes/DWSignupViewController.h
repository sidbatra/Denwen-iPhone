//
//  DWSignupViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWMediaPickerController.h"
#import "MBProgressHUD.h"

/**
 * Signup view for providing access to new users
 */
@interface DWSignupViewController : UIViewController<UITextFieldDelegate,DWMediaPickerControllerDelegate> {
	
	UIView              *_signupFieldsContainerView;
	UITextField         *_fullNameTextField;
	UITextField         *_emailTextField;
	UITextField         *_passwordTextField;
	UIBarButtonItem     *_doneButton;
	UIButton            *_imagePickerButton;
											
	MBProgressHUD       *mbProgressIndicator;
											
	NSString            *_photoFilename;										
	NSString            *_password;
	
	BOOL                _isUploading;
	BOOL                _signupInitiated;
    
	NSInteger           _uploadID;
}

/**
 * Filename of the user photo
 */
@property (nonatomic,copy) NSString *photoFilename;

/**
 * Encrypted password for the current user
 */
@property (nonatomic,copy) NSString *password;


/**
 * IBOutlet properties
 */
@property (nonatomic, retain) IBOutlet UIView *signupFieldsContainerView;
@property (nonatomic, retain) IBOutlet UITextField *fullNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *imagePickerButton;


/**
 * IBAction methods
 */
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)selectPhotoButtonClicked:(id)sender;

@end
