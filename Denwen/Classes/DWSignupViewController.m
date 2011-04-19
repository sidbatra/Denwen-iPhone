//
//  DWSignupViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWSignupViewController.h"
#import "DWConstants.h"

//Declarations for private methods
//
@interface DWSignupViewController () 
- (void)createNewUser;
- (void)freezeUI;
- (void)unfreezeUI ;
@end


@implementation DWSignupViewController

@synthesize signupFieldsContainerView,fullNameTextField,emailTextField,passwordTextField,doneButton,imagePickerButton,
				password=_password,photoFilename=_photoFilename;



#pragma mark -
#pragma mark View lifecycle


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
		
		
		self.photoFilename = [NSString stringWithFormat:@""];
		
		_signupInitiated = NO;
		_isUploading = NO;
		
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


// Additional UI configurations after the view has loaded
//
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:MODALVIEW_BACKGROUND_IMAGE]];
	
	//rounded corners and border customization
	[[signupFieldsContainerView layer] setCornerRadius:2.5f];
	//[[signupFieldsContainerView layer] setBorderWidth:1.0f];
	[[signupFieldsContainerView layer] setMasksToBounds:YES];
	//[[signupFieldsContainerView layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
	[[signupFieldsContainerView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	
	[[imagePickerButton layer] setCornerRadius:2.5f];
	//[[imagePickerButton layer] setBorderWidth:1.0f];
	[[imagePickerButton layer] setMasksToBounds:YES];
	//[[imagePickerButton layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
	
	[fullNameTextField becomeFirstResponder];
	
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];
}


// Message the delegate that the view has appeared. Used to hide the
// signup toolbar to allow the uiimagepicker to not be blocked
//
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[_delegate signupViewLoaded];
}


#pragma mark -
#pragma mark UI management

// Freezes the UI when the credentials are being evaluated on the server
//
- (void)freezeUI {
	[fullNameTextField resignFirstResponder];
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
	
	mbProgressIndicator.labelText = @"Signing Up";
	[mbProgressIndicator showUsingAnimation:YES];
}


// Restores the UI back to its normal state
- (void)unfreezeUI {
	[fullNameTextField becomeFirstResponder];
	
	[mbProgressIndicator hideUsingAnimation:YES];
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
    [self presentModalViewController:picker animated:NO];   
}


#pragma mark -
#pragma mark IB Events


// User clicks the cancel button
//
- (void)cancelButtonClicked:(id)sender {
	[_delegate signupViewCancelButtonClicked];
}


// User clicks the done button
//
- (void)doneButtonClicked:(id)sender {
	[self createNewUser];
}


// User wants to select  profile picture
//
- (IBAction)selectPhotoButtonClicked:(id)sender {
	[self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
}


// Handles return key on the keyboard
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if(textField == fullNameTextField) {
		[fullNameTextField resignFirstResponder];
		[emailTextField becomeFirstResponder];
	}
	if(textField == emailTextField) {
		[emailTextField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	}
	else if(textField == passwordTextField) {
		[self createNewUser];
	}
	
	return YES;
}



#pragma mark -
#pragma mark Server interaction methods


// POST the user's signup information to creat a new account
//
- (void)createNewUser {
	
	if (emailTextField.text.length == 0 || fullNameTextField.text.length == 0 || passwordTextField.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Fields" 
														message:EMPTY_LOGIN_FIELDS_MSG
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else {			
		if(!_signupInitiated)
			[self freezeUI];
		
		if(!_isUploading) {
			
			_signupInitiated = NO;
				
			self.password = [passwordTextField.text isEqualToString:@""] ? passwordTextField.text : 
							[[passwordTextField.text encrypt] stringByEncodingHTMLCharacters];
			
			[[DWRequestsManager sharedDWRequestsManager] createUserWithName:fullNameTextField.text 
																  withEmail:emailTextField.text
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
#pragma mark DWMediaPickerControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingImage:(UIImage*)originalImage 
				  andEditedTo:(UIImage*)editedImage {
	
	[self dismissModalViewControllerAnimated:NO];
    _isUploading = YES;
	
	_uploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:editedImage
                                                                        toFolder:kS3UsersFolder
                                                              withUploadDelegate:nil];
	
    UIImage *resizedImage = [editedImage resizeTo:CGSizeMake(SIZE_USER_PRE_UPLOAD_IMAGE,
                                                             SIZE_USER_PRE_UPLOAD_IMAGE)];
    
	[imagePickerButton setBackgroundImage:resizedImage 
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



#pragma mark -
#pragma mark Notifications

- (void)userCreated:(NSNotification*)notification {
	
	NSDictionary *info = [notification userInfo];
	NSDictionary *body = [info objectForKey:kKeyBody];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		NSDictionary *userJSON = [body objectForKey:USER_JSON_KEY];
		
		DWUser *user = [[DWUser alloc] init];
		[user populate:userJSON];
		user.encryptedPassword = self.password;
		
		[[DWSession sharedDWSession] create:user];
		[_delegate signupSuccessful];		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNUserLogsIn object:user];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:[[body objectForKey:USER_JSON_KEY] objectForKey:ERROR_MESSAGES_JSON_KEY]
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self unfreezeUI];
	}
	
}

- (void)userError:(NSNotification*)notification {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Problem connecting to the server, please try again"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[self unfreezeUI];	
}

- (void)imageUploadDone:(NSNotification*)notification {
	
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		_isUploading = NO;
		
		self.photoFilename = [info objectForKey:kKeyFilename];
		
		if(_signupInitiated)
			[self createNewUser];		
	}
}


- (void)imageUploadError:(NSNotification*)notification {
	
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		_isUploading = NO;
		_signupInitiated = NO;
		
		[self unfreezeUI];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"There was an error uploading your image. Please try again."
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];		
	}
}


#pragma mark -
#pragma mark Memory management


// The usual memory warning
//
- (void)didReceiveMemoryWarning {
	// Comment to preserve UIView elements in a 
	// low memory warning
    //[super didReceiveMemoryWarning];
}


// The usual memory cleanup
//
- (void)dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_delegate = nil;
	
	self.password = nil;
	self.photoFilename = nil;
		
	[fullNameTextField release];
	[emailTextField release];
	[passwordTextField release];
	[doneButton release];
	[imagePickerButton release];
	
    [super dealloc];
}


@end
