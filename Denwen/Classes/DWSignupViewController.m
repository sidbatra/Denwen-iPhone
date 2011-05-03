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
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"

static NSString* const kMsgProgressIndicator    = @"Signing Up";
static NSString* const kMsgIncompleteTitle      = @"Incomplete";
static NSString* const kMsgIncomplete           = @"Enter first name, last name, email and password";
static NSString* const kMsgErrorTitle           = @"Error";
static NSString* const kMsgErrorNetwork         = @"Please make sure you have network connectivity and try again";
static NSString* const kMsgCancelTitle          = @"OK";
static NSInteger const kPreviewSize             = 75;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSignupViewController

@synthesize password                    = _password;
@synthesize photoFilename               = _photoFilename;

@synthesize signupFieldsContainerView   = _signupFieldsContainerView;
@synthesize firstNameTextField          = _firstNameTextField;
@synthesize lastNameTextField           = _lastNameTextField;
@synthesize emailTextField              = _emailTextField;
@synthesize passwordTextField           = _passwordTextField;
@synthesize doneButton                  = _doneButton;
@synthesize imagePickerButton           = _imagePickerButton;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
        
		self.photoFilename  = [NSString stringWithFormat:@""];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userCreated:) 
													 name:kNNewUserCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userError:) 
													 name:kNNewUserError
												   object:nil];		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageUploadDone:) 
													 name:kNS3UploadDone
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageUploadError:) 
													 name:kNS3UploadError
												   object:nil];		
			
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.password                   = nil;
	self.photoFilename              = nil;
    
    self.signupFieldsContainerView  = nil;
	self.firstNameTextField         = nil;
    self.lastNameTextField          = nil;
	self.emailTextField             = nil;
	self.passwordTextField          = nil;
	self.doneButton                 = nil;
	self.imagePickerButton          = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self.signupFieldsContainerView layer] setCornerRadius:2.5f];
	[[self.signupFieldsContainerView layer] setMasksToBounds:YES];
	[[self.signupFieldsContainerView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	
	[[self.imagePickerButton layer] setCornerRadius:2.5f];
	[[self.imagePickerButton layer] setMasksToBounds:YES];
	
	[self.firstNameTextField becomeFirstResponder];
	
    mbProgressIndicator = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    
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
	[self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
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
                                                               withPhotoFilename:self.photoFilename];
		}
		else
			_signupInitiated = YES;
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private Methods
//----------------------------------------------------------------------------------------------------
-(void)presentMediaPickerControllerForPickerMode:(NSInteger)pickerMode {
    [[DWMemoryPool sharedDWMemoryPool] freeMemory];
    
    DWMediaPickerController *picker = [[[DWMediaPickerController alloc] initWithDelegate:self] autorelease];
    [picker prepareForImageWithPickerMode:pickerMode];
    
    [self presentModalViewController:picker 
                            animated:NO];   
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBAction methods

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
	[self createNewUser];
}

//----------------------------------------------------------------------------------------------------
- (void)selectPhotoButtonClicked:(id)sender {
	[self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
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
#pragma mark DWMediaPickerControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingImage:(UIImage*)originalImage 
				  andEditedTo:(UIImage*)editedImage {
	
	[self dismissModalViewControllerAnimated:NO];
    
    _isUploading                = YES;
	
	_uploadID                   = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:editedImage
                                                                                          toFolder:kS3UsersFolder
                                                                                withUploadDelegate:nil];
	
    UIImage *resizedImage       = [editedImage resizeTo:CGSizeMake(kPreviewSize,kPreviewSize)];
    
	[self.imagePickerButton setBackgroundImage:resizedImage 
                                      forState:UIControlStateNormal];	
}

//----------------------------------------------------------------------------------------------------
- (void)mediaPickerCancelledFromMode:(NSInteger)imagePickerMode {    
    [self dismissModalViewControllerAnimated:NO];  
    
    if (imagePickerMode == kMediaPickerLibraryMode)
        [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
}

//----------------------------------------------------------------------------------------------------
- (void)photoLibraryModeSelected {
    [self dismissModalViewControllerAnimated:NO];
    [self presentMediaPickerControllerForPickerMode:kMediaPickerLibraryMode];
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

//----------------------------------------------------------------------------------------------------
- (void)imageUploadDone:(NSNotification*)notification {
	
	NSDictionary *info      = [notification userInfo];
	NSInteger resourceID    = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		
        _isUploading        = NO;
		self.photoFilename  = [info objectForKey:kKeyFilename];
		
		if(_signupInitiated)
			[self createNewUser];		
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imageUploadError:(NSNotification*)notification {
	
	NSDictionary *info      = [notification userInfo];
	NSInteger resourceID    = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
        
		_isUploading        = NO;
		_signupInitiated    = NO;
		
		[self unfreezeUI];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorTitle
														message:kMsgErrorNetwork
													   delegate:nil 
											  cancelButtonTitle:kMsgCancelTitle
											  otherButtonTitles: nil];
		[alert show];
		[alert release];		
	}
}


@end
