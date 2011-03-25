//
//  DWNewItemViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWNewItemViewController.h"


//Declarations for private methods
//
@interface DWNewItemViewController () 
- (void)createNewItem;
@end

@implementation DWNewItemViewController


@synthesize textView,placeLabel,imagePickerButton,imagePlaceholder,navItem,imagePreview,placeName=_placeName,filename=_filename;


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate withPlaceName:(NSString*)placeName withPlaceID:(int)placeID withForcePost:(bool)forcePost {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
		
		self.placeName = placeName;
		self.filename = [NSString stringWithFormat:@""];
		
		_placeID = placeID;
		
		_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
		_s3Uploader = [[DWS3Uploader alloc] initWithDelegate:self];
		
		_forcePost = forcePost; //_forcePost forces the user to create a post before exiting
		_postInitiated = NO;
		_isUploading = NO;
		_isLoadedOnce = NO;
	}
	return self;
}


// Additional UI configurations after the view has loaded
//
- (void)viewDidLoad {
    [super viewDidLoad];
		
	[textView becomeFirstResponder];
	textView.placeholderText = NEW_POST_TEXTVIEW_PLACEHOLDER_TEXT;
	placeLabel.text = [NSString stringWithFormat:@"%@",_placeName];
		
	// Hide the cancel button if forcePost flag is on
	if(_forcePost)
		navItem.leftBarButtonItem = nil;
	
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];
	
	_isLoadedOnce = YES;
}



#pragma mark -
#pragma mark UI management


// Freezes the UI when the credentials are being evaluated on the server
//
- (void)freezeUI {
	[textView resignFirstResponder];
	
	mbProgressIndicator.labelText = @"Posting...";
	[mbProgressIndicator showUsingAnimation:YES];
}


// Restores the UI back to its normal state
- (void)unfreezeUI {
	[textView becomeFirstResponder];

	[mbProgressIndicator hideUsingAnimation:YES];
}


// Limit the number of characters in the textView
//
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   
	NSUInteger newLength = [theTextView.text length] + [text length] - range.length;
    return (newLength > MAX_POST_DATA_LENGTH) ? NO : YES;
}


#pragma mark -
#pragma mark Server interaction methods


// POST data about the new item to the server
//
- (void)createNewItem {
	
	if (textView.text.length == 0 && !imagePreview.image) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Fields" 
														message:EMPTY_POST_MSG
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else {
		if(!_postInitiated) 
			[self freezeUI];
		
		if(!_isUploading) {
			_postInitiated = NO;
			NSString *postString = [[NSString alloc] initWithFormat:@"item[data]=%@&item[place_id]=%d&email=%@&password=%@&attachment[filename]=%@&ff=mobile",
									[textView.text stringByEncodingHTMLCharacters],
									_placeID,
									currentUser.email,
									currentUser.encryptedPassword,
									self.filename
									];
			
			[_requestManager sendPostRequest:ITEMS_URI withParams:postString];
			[postString release];
		}
		else
			_postInitiated = YES;
	}
}



#pragma mark -
#pragma mark Inteface builder events

// User clicks the cancel button
//
- (void)cancelButtonClicked:(id)sender {
	[_delegate newItemCancelled];
}


// User clicks the post button
//
- (void)postButtonClicked:(id)sender {
	[self createNewItem];
}


// User wants to add photo to the item
//
- (void)selectPhotoButtonClicked:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
													cancelButtonTitle:CANCEL_MEDIA_MSG	destructiveButtonTitle:nil
													otherButtonTitles:TAKE_MEDIA_MSG,CHOOSE_MEDIA_MSG,nil];
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
		imagePickerController.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.mediaTypes = [UIImagePickerController  availableMediaTypesForSourceType:imagePickerController.sourceType];   
		imagePickerController.videoMaximumDuration = VIDEO_MAX_DURATION;
		imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
		[self presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
	}
}	



#pragma mark -
#pragma mark UIImagePickerControllerDelegate


// Called when a user chooses a picture from the library of the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *previewImage = nil;
	NSURL *mediaURL = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
	BOOL isImageFile = mediaURL == nil;
	
	
	if(isImageFile) {
		UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
		UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
		
		previewImage = [DWImageHelper resizeImage:image 
											  scaledToSize:CGSizeMake(SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE,SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE)];
		
		[_s3Uploader uploadImage:image toFolder:S3_ITEMS_FOLDER];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}
	else {
		NSString *orientation = [DWVideoHelper extractOrientationOfVideo:mediaURL];
		NSData *videoData = [[NSData alloc] initWithContentsOfURL:mediaURL];
		
		previewImage = [UIImage imageNamed:VIDEO_TINY_PREVIEW_PLACEHOLDER_IMAGE_NAME];
		
		[_s3Uploader uploadVideo:videoData atOrientation:orientation toFolder:S3_ITEMS_FOLDER];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
		
		[videoData release];
	}
	
	imagePlaceholder.hidden = NO;
	imagePreview.image = previewImage;

	[self dismissModalViewControllerAnimated:YES];
	_isUploading = YES;
}


// Called when user cancels the photo selection / creation process
//
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}


// Called when the image is saved to the disk
//
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	/* TODO
	 UIAlertView *alert;
	 
	 // Unable to save the image  
	 if (error) {
	 alert = [[UIAlertView alloc] initWithTitle:@"Error" 
	 message:@"Unable to save image to Photo Album." 
	 delegate:self cancelButtonTitle:@"Ok" 
	 otherButtonTitles:nil];
	 else 
	 
	 [alert show];
	 [alert release]; 
	 */
}


// Called when the video is saved to the disk
//
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	//NSLog(@"video saved %@",[error localizedDescription]);
	// TODO: Record errors
}



#pragma mark -
#pragma mark DWRequestManagerDelegate


// Fired when request manager has successfully parsed a request
//
- (void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			 withMessage:(NSString*)message withInstanceID:(int)instanceID {

	if([status isEqualToString:SUCCESS_STATUS]) {
		DWItem *item = [[DWItem alloc] init];
		[item populate:[body objectForKey:ITEM_JSON_KEY]];
		item.fromFollowedPlace = [[body objectForKey:FOLLOWING_JSON_KEY] boolValue];
		
		[DWMemoryPool setObject:item atRow:ITEMS_INDEX];
		item.pointerCount--;
		[item release];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_NEW_ITEM_CREATED object:item];
		[_delegate newItemCreationFinished];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:[[body objectForKey:ITEM_JSON_KEY] objectForKey:ERROR_MESSAGES_JSON_KEY]
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
#pragma mark DWS3UploaderDelegate


// Media has been successfully uploaded to S3
//
- (void)finishedUploadingMedia:(NSString*)filename {
	_isUploading = NO;
		
	self.filename = filename;
	
	if(_postInitiated)
		[self createNewItem];
}


// An error happened while uploading media to S3
//
- (void)errorUploadingMedia:(NSError*)error {
	_isUploading = NO;
	_postInitiated = NO;
	imagePreview.image = nil;
	imagePlaceholder.hidden = YES;
	
	[self unfreezeUI];
		
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"There was an error uploading your file. Please try again."
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}




#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[super viewDidUnload];
}

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
	//Comment out to preserve text and chosen item image
	//during a memory warning
    //[super didReceiveMemoryWarning];
}


// The usual cleanup
//
- (void)dealloc {
	_delegate = nil;
	
	self.placeName = nil;
	self.filename = nil;
	
	[_requestManager release];
	[_s3Uploader release];
	
	[textView release];
	[placeLabel release];
	[imagePickerButton release];
	[navItem release];
	[imagePreview release];
	[imagePlaceholder release];
	
    [super dealloc];
}


@end
