//
//  DWLoginViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWLoginViewController.h"


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
		_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
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
						[[DWCrypto encryptString:passwordTextField.text] stringByEncodingHTMLCharacters];
		

		NSString *postString = [[NSString alloc] initWithFormat:@"email=%@&password=%@&ff=mobile",
							   emailTextField.text,
								self.password
								];
		[_requestManager sendPostRequest:LOGIN_URI withParams:postString];

		[postString release];
	}
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
- (void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			 withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		
		DWUser *user = [[DWUser alloc] init];
		[user populate:[body objectForKey:USER_JSON_KEY]];
		user.encryptedPassword = self.password;
		[DWSessionManager createSessionWithUser:user];

		[_delegate loginSuccessful];
		[[NSNotificationCenter defaultCenter] postNotificationName:N_USER_LOGS_IN object:user];
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


// Fired when an error happens during the request
//
- (void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	
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
	_delegate = nil;
	
	self.password = nil;
	
	[_requestManager release];
	
	[emailTextField release];
	[passwordTextField release];
	[doneButton release];
	
    [super dealloc];
}


@end
