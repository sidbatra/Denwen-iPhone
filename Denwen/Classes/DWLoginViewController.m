//
//  DWLoginViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWLoginViewController.h"
#import "DWMemoryPool.h"
#import "DWUser.h"
#import "DWRequestsManager.h"
#import "DWSession.h"
#import "DWGUIManager.h"
#import "NSString+Helpers.h"
#import "DWConstants.h"

static NSString* const kMsgProgressIndicator    = @"Logging In";
static NSString* const kMsgIncompleteTitle      = @"Incomplete";
static NSString* const kMsgIncomplete           = @"Enter email and password";
static NSString* const kMsgErrorTitle           = @"Error";
static NSString* const kMsgErrorLogin           = @"Incorrect email or password";
static NSString* const kMsgErrorNetwork         = @"Please make sure you have network connectivity and try again";
static NSString* const kMsgCancelTitle          = @"OK";
static NSString* const kLoginText               = @"Log In";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWLoginViewController

@synthesize password                    = _password;

@synthesize loginFieldsContainerView    = _loginFieldsContainerView;
@synthesize emailTextField              = _emailTextField;
@synthesize passwordTextField           = _passwordTextField;

@synthesize customNavBar                = _customNavBar;
@synthesize doneButtonView              = _doneButtonView;


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
    
	self.doneButtonView             = nil;
    self.customNavBar               = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.customNavBar.topItem setLeftBarButtonItem:[DWGUIManager customBackButton:self]];
    self.customNavBar.topItem.titleView = [DWGUIManager customTitleWithText:kLoginText];
    
    if (!self.doneButtonView)
        self.doneButtonView = [[[DWDoneButtonView alloc] 
                                initWithFrame:CGRectMake(260,0,
                                                         kNavTitleViewWidth,
                                                         kNavTitleViewHeight) 
                                andTarget:self] autorelease];
    
    [self.customNavBar addSubview:self.doneButtonView];
	
	[[self.loginFieldsContainerView layer] setCornerRadius:2.5f];
	
	[self.emailTextField becomeFirstResponder];
	
    mbProgressIndicator         = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    mbProgressIndicator.frame   = CGRectMake(mbProgressIndicator.frame.origin.x,
                                             mbProgressIndicator.frame.origin.y-87,
                                             mbProgressIndicator.frame.size.width,
                                             mbProgressIndicator.frame.size.height+1);
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
	//[self.emailTextField resignFirstResponder];
	//[self.passwordTextField resignFirstResponder];
	
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
- (void)didTapBackButton:(id)sender event:(id)event {
    [self.navigationController popViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapDoneButton:(id)sender event:(id)event {
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
