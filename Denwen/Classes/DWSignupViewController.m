//
//  DWSignupViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSignupViewController.h"
#import "DWUser.h"
#import "DWRequestsManager.h"
#import "NSString+Helpers.h"
#import "DWSession.h"
#import "DWMemoryPool.h"
#import "DWConstants.h"
#import "DWGUIManager.h"

static NSString* const kMsgProgressIndicator    = @"Signing Up";
static NSString* const kMsgIncompleteTitle      = @"Incomplete";
static NSString* const kMsgIncomplete           = @"Enter first name, last name, email and password";
static NSString* const kMsgErrorTitle           = @"Error";
static NSString* const kMsgErrorNetwork         = @"Please make sure you have network connectivity and try again";
static NSString* const kMsgCancelTitle          = @"OK";
static NSInteger const kPreviewSize             = 75;
static NSString* const kSignUpText              = @"Sign Up";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSignupViewController

@synthesize password                    = _password;

@synthesize signupFieldsContainerView   = _signupFieldsContainerView;
@synthesize firstNameTextField          = _firstNameTextField;
@synthesize lastNameTextField           = _lastNameTextField;
@synthesize emailTextField              = _emailTextField;
@synthesize passwordTextField           = _passwordTextField;

@synthesize customNavBar                = _customNavBar;
@synthesize doneButtonView              = _doneButtonView;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
        
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userCreated:) 
													 name:kNNewUserCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userError:) 
													 name:kNNewUserError
												   object:nil];
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.password                   = nil;
    
    self.signupFieldsContainerView  = nil;
	self.firstNameTextField         = nil;
    self.lastNameTextField          = nil;
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
    self.customNavBar.topItem.titleView = [DWGUIManager customTitleWithText:kSignUpText];
    
    if (!self.doneButtonView)
        self.doneButtonView = [[[DWDoneButtonView alloc] 
                                initWithFrame:CGRectMake(260,0,
                                                         kNavTitleViewWidth,
                                                         kNavTitleViewHeight) 
                                andTarget:self] autorelease];
    
    [self.customNavBar addSubview:self.doneButtonView];
	
	[[self.signupFieldsContainerView layer] setCornerRadius:2.5f];
	
	[self.firstNameTextField becomeFirstResponder];
	
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
    //[super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)freezeUI {
	//[self.firstNameTextField resignFirstResponder];
    //[self.lastNameTextField resignFirstResponder];
	//[self.emailTextField resignFirstResponder];
	//[self.passwordTextField resignFirstResponder];
	
	mbProgressIndicator.labelText = kMsgProgressIndicator;
	[mbProgressIndicator showUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)unfreezeUI {
	[self.firstNameTextField becomeFirstResponder];
	
	[mbProgressIndicator hideUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)createNewUser {
	
	if (self.emailTextField.text.length == 0 || 
        self.firstNameTextField.text.length == 0 ||
        self.lastNameTextField.text.length == 0 ||
        self.passwordTextField.text.length == 0) {
        
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgIncompleteTitle
														message:kMsgIncomplete
													   delegate:nil 
											  cancelButtonTitle:kMsgCancelTitle
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else {			
		if(!_signupInitiated)
			[self freezeUI];
		
		if(!_isUploading) {
			
			_signupInitiated    = NO;
			self.password       = [[self.passwordTextField.text encrypt] stringByEncodingHTMLCharacters];
			
            
			[[DWRequestsManager sharedDWRequestsManager] createUserWithFirstName:self.firstNameTextField.text 
                                                                    withLastName:self.lastNameTextField.text
                                                                       withEmail:self.emailTextField.text
                                                                    withPassword:self.password
                                                               withPhotoFilename:kEmptyString];
		}
		else
			_signupInitiated    = YES;
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBAction methods
//----------------------------------------------------------------------------------------------------
- (void)didTapBackButton:(id)sender event:(id)event {
    [self.navigationController popViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapDoneButton:(id)sender event:(id)event {
	[self createNewUser];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if(textField == self.firstNameTextField) {
		[self.firstNameTextField resignFirstResponder];
		[self.lastNameTextField becomeFirstResponder];
	}
    else if(textField == self.lastNameTextField) {
        [self.lastNameTextField resignFirstResponder];
        [self.emailTextField becomeFirstResponder];
    }
	if(textField == self.emailTextField) {
		[self.emailTextField resignFirstResponder];
		[self.passwordTextField becomeFirstResponder];
	}
	else if(textField == self.passwordTextField) {
		[self createNewUser];
	}
	
	return YES;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)userCreated:(NSNotification*)notification {
	
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
														message:[[body objectForKey:kKeyUser] objectForKey:kKeyErrorMessages]
													   delegate:nil 
											  cancelButtonTitle:kMsgCancelTitle
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self unfreezeUI];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (void)userError:(NSNotification*)notification {
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
