//
//  DWLoginViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"

/**
 * Login view for giving access to existing users
 */
@interface DWLoginViewController : UIViewController<UITextFieldDelegate> {
	UIView              *_loginFieldsContainerView;
	UITextField         *_emailTextField;
	UITextField         *_passwordTextField;
	UIBarButtonItem     *_doneButton;
	
	NSString            *_password;
	
	MBProgressHUD       *mbProgressIndicator;
}

/**
 * Encrypted user password
 */
@property (nonatomic,copy) NSString *password;

/**
 * IBOutlets
 */
@property (nonatomic,retain) IBOutlet UIView *loginFieldsContainerView;
@property (nonatomic,retain) IBOutlet UITextField *emailTextField;
@property (nonatomic,retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *doneButton;


/**
 * IBAction methods
 */
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end