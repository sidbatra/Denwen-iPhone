//
//  DWSignupViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWSignupViewController.h"


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
		
		_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
		_s3Uploader = [[DWS3Uploader alloc] initWithDelegate:self];
		
		self.photoFilename = [NSString stringWithFormat:@""];
		
		_signupInitiated = NO;
		_isUploading = NO;
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
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
														cancelButtonTitle:CANCEL_PHOTO_MSG	destructiveButtonTitle:nil
														otherButtonTitles:FIRST_TAKE_PHOTO_MSG,FIRST_CHOOSE_PHOTO_MSG,nil];
	[actionSheet showInView:self.view];	
	[actionSheet release];
}


// Handle clicks on the Photo modality selection action sheet
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	//Ignore event for the cancel button
	if(buttonIndex != 2) {
		[DWMemoryPool freeMemory];
		
		UIImagePickerController *imagePickerController = imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;		
		imagePickerController.sourceType =  buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
	}
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
			
			NSString *postString  = [[NSString alloc] initWithFormat:@"user[full_name]=%@&user[email]=%@&user[password]=%@&user[photo_filename]=%@&ff=mobile",
											   [fullNameTextField.text stringByEncodingHTMLCharacters],
											   emailTextField.text,
											   self.password,
											   self.photoFilename
											   ];

			[_requestManager sendPostRequest:SIGNUP_URI withParams:postString];
			[postString release];
		}
		else
			_signupInitiated = YES;
	}
}



#pragma mark -
#pragma mark UIImagePickerControllerDelegate


// Called when a user chooses a picture from the library of the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
	UIImage *resizedImage = [image resizeTo:CGSizeMake(SIZE_USER_PRE_UPLOAD_IMAGE,SIZE_USER_PRE_UPLOAD_IMAGE)];
	
	[imagePickerButton setBackgroundImage:resizedImage forState:UIControlStateNormal];
	
	[self dismissModalViewControllerAnimated:YES];
	
	_isUploading = YES;
	[_s3Uploader uploadImage:image toFolder:S3_USERS_FOLDER];
}


// Called when user cancels the photo selection / creation process
//
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
- (void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			 withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		NSDictionary *userJSON = [body objectForKey:USER_JSON_KEY];
		
		DWUser *user = [[DWUser alloc] init];
		[user populate:userJSON];
		user.encryptedPassword = self.password;
		
		[[DWSession sharedDWSession] create:user];
		[_delegate signupSuccessful];		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_USER_LOGS_IN object:user];
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
#pragma mark S3 Uploader Delegate methods


// Media has been successfully uploaded to S3
//
- (void)finishedUploadingMedia:(NSString*)filename {
	_isUploading = NO;
	
	self.photoFilename = filename;
	
	if(_signupInitiated)
		[self createNewUser];
}


// An error happened while uploading media to S3
//
- (void)errorUploadingMedia:(NSError*)error {
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
	_delegate = nil;
	
	self.password = nil;
	self.photoFilename = nil;
	
	[_requestManager release];
	[_s3Uploader release];
	
	[fullNameTextField release];
	[emailTextField release];
	[passwordTextField release];
	[doneButton release];
	[imagePickerButton release];
	
    [super dealloc];
}


@end
