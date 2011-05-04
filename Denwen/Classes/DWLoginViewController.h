//
//  DWLoginViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"
#import "DWNavigationBar.h"
#import "DWDoneButtonView.h"

/**
 * Login view for giving access to existing users
 */
@interface DWLoginViewController : UIViewController<UITextFieldDelegate> {
	UIView              *_loginFieldsContainerView;
	UITextField         *_emailTextField;
	UITextField         *_passwordTextField;
    
	NSString            *_password;
    
    DWNavigationBar     *_customNavBar;    	
    DWDoneButtonView    *_doneButtonView;
	MBProgressHUD       *mbProgressIndicator;
}

/**
 * Encrypted user password
 */
@property (nonatomic,copy) NSString *password;

/**
 * Subview for displaying the done button
 */
@property (nonatomic,retain) DWDoneButtonView *doneButtonView;


/**
 * IBOutlets
 */
@property (nonatomic, retain) IBOutlet UIView *loginFieldsContainerView;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet DWNavigationBar *customNavBar;


@end