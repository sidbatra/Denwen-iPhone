//
//  DWLoginViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWLoginViewController.h"
#import "DWMemoryPool.h"
#import "DWUser.h"
#import "DWRequestsManager.h"
#import "DWSession.h"
#import "NSString+Helpers.h"
#import "DWConstants.h"

static NSString* const kMsgProgressIndicator    = @"Logging In";
static NSString* const kMsgIncompleteTitle      = @"Incomplete";
static NSString* const kMsgIncomplete           = @"Enter email and password";
static NSString* const kMsgErrorTitle           = @"Error";
static NSString* const kMsgErrorLogin           = @"Incorrect email or password";
static NSString* const kMsgErrorNetwork         = @"Please make sure you have network connectivity and try again";
static NSString* const kMsgCancelTitle          = @"OK";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWLoginViewController

@synthesize password                    = _password;
@synthesize loginFieldsContainerView    = _loginFieldsContainerView;
@synthesize emailTextField              = _emailTextField;
@synthesize passwordTextField           = _passwordTextField;
@synthesize doneButton                  = _doneButton;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		
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

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	
	self.password                   = nil;
    
    self.loginFieldsContainerView   = nil;
	self.emailTextField             = nil;
	self.passwordTextField          = nil;
	self.doneButton                 = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self.loginFieldsContainerView layer] setCornerRadius:2.5f];
	[[self.loginFieldsContainerView layer] setMasksToBounds:YES];
	
	[self.emailTextField becomeFirstResponder];
	
    mbProgressIndicator = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    
	[self.view addSubview:mbProgressIndicator];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)freezeUI {
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
	mbProgressIndicator.labelText = kMsgProgressIndicator;
	[mbProgressIndicator showUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)unfreezeUI {
	[mbProgressIndicator hideUsingAnimation:YES];
	[self.emailTextField becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)authenticateCredentials {
	if (self.emailTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgIncompleteTitle
														message:kMsgIncomplete
													   delegate:nil 
											  cancelButtonTitle:kMsgCancelTitle
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else {
		[self freezeUI];
		
		self.password = [[self.passwordTextField.text encrypt] stringByEncodingHTMLCharacters];
        
		[[DWRequestsManager sharedDWRequestsManager] createSessionWithEmail:self.emailTextField.text 
															   withPassword:self.password];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
	[self authenticateCredentials];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if(textField == self.emailTextField) {
		[self.emailTextField resignFirstResponder];
		[self.passwordTextField becomeFirstResponder];
	}
	else if(textField == self.passwordTextField) {
		[self authenticateCredentials];
	}

	return YES;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)sessionCreated:(NSNotification*)notification {
	
	NSDictionary *info = [notification userInfo];
	NSDictionary *body = [info objectForKey:kKeyBody];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {

        DWUser *user            = (DWUser*)[[DWMemoryPool sharedDWMemoryPool] getOrSetObject:[body objectForKey:kKeyUser]
                                                                                       atRow:kMPUsersIndex];
		user.encryptedPassword  = self.password;
		[[DWSession sharedDWSession] create:user];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNUserLogsIn 
                                                            object:user];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorTitle
														message:kMsgErrorLogin
													   delegate:nil 
											  cancelButtonTitle:kMsgCancelTitle
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self unfreezeUI];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)sessionError:(NSNotification*)notification {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorTitle
													message:kMsgErrorNetwork
												   delegate:nil 
										  cancelButtonTitle:kMsgCancelTitle
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[self unfreezeUI];
}

@end
