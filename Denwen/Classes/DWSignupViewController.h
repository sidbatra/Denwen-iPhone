//
//  DWSignupViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWMediaPickerController.h"
#import "MBProgressHUD.h"
#import "DWNavigationBar.h"
#import "DWDoneButtonView.h"

/**
 * Signup view for providing access to new users
 */
@interface DWSignupViewController : UIViewController<UITextFieldDelegate> {
	
	UIView              *_signupFieldsContainerView;
	UITextField         *_firstNameTextField;
    UITextField         *_lastNameTextField;
	UITextField         *_emailTextField;
	UITextField         *_passwordTextField;
			
    DWNavigationBar     *_customNavBar;    	
    DWDoneButtonView    *_doneButtonView;
	MBProgressHUD       *mbProgressIndicator;
																				
	NSString            *_password;
	
	BOOL                _isUploading;
	BOOL                _signupInitiated;
    
	NSInteger           _uploadID;
}

/**
 * Encrypted password for the current user
 */
@property (nonatomic,copy) NSString *password;

/**
 * Subview for displaying the done button
 */
@property (nonatomic,retain) DWDoneButtonView *doneButtonView;


/**
 * IBOutlet properties
 */
@property (nonatomic, retain) IBOutlet UIView *signupFieldsContainerView;
@property (nonatomic, retain) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet DWNavigationBar *customNavBar;


@end
