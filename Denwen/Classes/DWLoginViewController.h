//
//  DWLoginViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWUser.h"
#import "DWRequestManager.h"
#import "DWSessionManager.h"
#import "DWCrypto.h"
#import "DWURLHelper.h"
#import "MBProgressHUD.h"

@protocol DWLoginViewControllerDelegate;


@interface DWLoginViewController : UIViewController<UITextFieldDelegate,DWRequestManagerDelegate> {
	UIView *loginFieldsContainerView;
	UITextField *emailTextField;
	UITextField *passwordTextField;
	UIBarButtonItem *doneButton;
	
	DWRequestManager *_requestManager;
	NSString *_password;
	
	MBProgressHUD *mbProgressIndicator;
	id <DWLoginViewControllerDelegate> _delegate;
}

@property (nonatomic,retain) IBOutlet UIView *loginFieldsContainerView;
@property (nonatomic,retain) IBOutlet UITextField *emailTextField;
@property (nonatomic,retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *doneButton;

@property (copy) NSString *password;


- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end


@protocol DWLoginViewControllerDelegate
- (void)loginViewCancelButtonClicked;
- (void)loginSuccessful;
@end