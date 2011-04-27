//
//  DWLoginViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWLoginViewController.h"
#import "DWMemoryPool.h"
#import "DWConstants.h"

//Declarations for private methods
//
@interface DWLoginViewController () 
- (void)authenticateCredentials;
- (void)freezeUI;
- (void)unfreezeUI ;
@end


@implementation DWLoginViewController

@synthesize loginFieldsContainerView,emailTextField,passwordTextField,doneButton,password=_password;

#pragma mark -
#pragma mark View lifecycle


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(sessionCreated:) 
													 name:kNNewSessionCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(sessionError:) 
													 name:kNNewSessionError
												   object:nil];	
	}
	return self;
}


// Additional UI configurations after the view has loaded
//
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:MODALVIEW_BACKGROUND_IMAGE]];
	
	//rounded corners and border customization
	[[loginFieldsContainerView layer] setCornerRadius:2.5f];
	//[[loginFieldsContainerView layer] setBorderWidth:1.0f];
	[[loginFieldsContainerView layer] setMasksToBounds:YES];
	//[[loginFieldsContainerView layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
	
	[emailTextField becomeFirstResponder];
	
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];

}



#pragma mark -
#pragma mark UI management

// Freezes the UI when the credentials are being evaluated on the server
//
- (void)freezeUI {
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
	
	mbProgressIndicator.labelText = @"Logging In";
	[mbProgressIndicator showUsingAnimation:YES];
}


// Restores the UI back to its normal state
//
- (void)unfreezeUI {
	[mbProgressIndicator hideUsingAnimation:YES];
	[emailTextField becomeFirstResponder];
}



#pragma mark -
#pragma mark IB Events

// User clicks the signup button
//
- (void)cancelButtonClicked:(id)sender {
	[_delegate loginViewCancelButtonClicked];
}

// User clicks the done button
//
- (void)doneButtonClicked:(id)sender {
	[self authenticateCredentials];
}


// Handles return key on the keyboard
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if(textField == emailTextField) {
		[emailTextField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	}
	else if(textField == passwordTextField) {
		[self authenticateCredentials];
	}

	return YES;
}



#pragma mark -
#pragma mark Server interaction method


// Sends the credentials to the server to test if login information is valid
//
- (void)authenticateCredentials {
	if (emailTextField.text.length == 0 || passwordTextField.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Fields" 
														message:EMPTY_LOGIN_FIELDS_MSG
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else {
		[self freezeUI];
		
		self.password = [passwordTextField.text isEqualToString:@""] ? passwordTextField.text : 
						[[passwordTextField.text encrypt] stringByEncodingHTMLCharacters];
		
		[[DWRequestsManager sharedDWRequestsManager] createSessionWithEmail:emailTextField.text 
															   withPassword:self.password];
	}
}



#pragma mark -
#pragma mark Notifications

- (void)sessionCreated:(NSNotification*)notification {
	
	NSDictionary *info = [notification userInfo];
	NSDictionary *body = [info objectForKey:kKeyBody];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {

        DWUser *user            = (DWUser*)[[DWMemoryPool sharedDWMemoryPool] getOrSetObject:[body objectForKey:kKeyUser]
                                                                                       atRow:kMPUsersIndex];
		user.encryptedPassword  = self.password;
		[[DWSession sharedDWSession] create:user];
		
		[_delegate loginSuccessful];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNUserLogsIn 
                                                            object:user];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"Username or passoword incorrect"
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self unfreezeUI];
	}
	
	
}


- (void)sessionError:(NSNotification*)notification {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Problem connecting to the server, please try again"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[self unfreezeUI];
}



#pragma mark -
#pragma mark Memory management


// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// The usual memory cleanup
//
- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_delegate = nil;
	
	self.password = nil;
		
	[emailTextField release];
	[passwordTextField release];
	[doneButton release];
	
    [super dealloc];
}


@end
