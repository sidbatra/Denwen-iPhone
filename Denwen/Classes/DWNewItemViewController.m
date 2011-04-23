//
//  DWNewItemViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWNewItemViewController.h"
#import "DWConstants.h"


//Declarations for private methods
//
@interface DWNewItemViewController () 
- (void)createNewItem;
@end

@implementation DWNewItemViewController


@synthesize textView,placeLabel,imagePickerButton,imagePlaceholder,navItem,imagePreview,placeName=_placeName,filename=_filename,
            imagePicker = _imagePicker;


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate withPlaceName:(NSString*)placeName withPlaceID:(int)placeID withForcePost:(bool)forcePost {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
		
		self.placeName = placeName;
		self.filename = [NSString stringWithFormat:@""];
		
		_placeID = placeID;
		
		
		_forcePost = forcePost; //_forcePost forces the user to create a post before exiting
		_postInitiated = NO;
		_isUploading = NO;
		_isLoadedOnce = NO;
        
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemCreated:) 
													 name:kNNewItemCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemError:) 
													 name:kNNewItemError
												   object:nil];		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediaUploaded:) 
													 name:kNS3UploadDone
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediaUploadError:) 
													 name:kNS3UploadError
												   object:nil];		
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
   
	return YES;
	//NSUInteger newLength = [theTextView.text length] + [text length] - range.length;
    //return (newLength > MAX_POST_DATA_LENGTH) ? NO : YES;
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
			
			[[DWRequestsManager sharedDWRequestsManager] createItemWithData:textView.text 
													 withAttachmentFilename:self.filename 
															  atPlaceWithID:_placeID];
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
													cancelButtonTitle:kMsgCancelMedia	destructiveButtonTitle:nil
													otherButtonTitles:kMsgTakeMedia,kMsgChooseMedia,nil];
	[actionSheet showInView:self.view];	
	[actionSheet release];	
}


// Handle clicks on the Photo modality selection action sheet
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	//Ignore event for the cancel button
	if(buttonIndex != 2) {
		[[DWMemoryPool sharedDWMemoryPool]  freeMemory];
		
        //self.imagePicker = [[[DWMediaPickerController alloc] initWithDelegate:self] autorelease];
        //[self.imagePicker prepareForMedia:buttonIndex];
		//[self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
	}
}	



#pragma mark -
#pragma mark DWMediaPickerController Delegate


- (void)mediaPickedAndProcessedWithID:(NSInteger)uploadID andPreview:(UIImage*)previewImage {
	/*imagePlaceholder.hidden = NO;
	imagePreview.image = previewImage;
    _uploadID = uploadID;
    _isUploading = YES;

	[self dismissModalViewControllerAnimated:YES];
    self.imagePicker = nil;
	 */
}


- (void)mediaCancelled {
	/*
	[self dismissModalViewControllerAnimated:YES];
    self.imagePicker = nil;
	 */
}



#pragma mark -
#pragma mark Notifications

- (void)itemCreated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	NSDictionary *body = [info objectForKey:kKeyBody];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		DWItem *item = [[DWItem alloc] init];
		[item populate:[body objectForKey:ITEM_JSON_KEY]];
		
		[[DWMemoryPool sharedDWMemoryPool]  setObject:item atRow:kMPItemsIndex];
		item.pointerCount--;
		[item release];
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:N_NEW_ITEM_CREATED object:item];
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

- (void)itemError:(NSNotification*)notification {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Problem connecting to the server, please try again"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[self unfreezeUI];
}

- (void)mediaUploaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		_isUploading = NO;
		
		self.filename = [info objectForKey:kKeyFilename];
		
		if(_postInitiated)
			[self createNewItem];
	}
}

- (void)mediaUploadError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
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
		
	[textView release];
	[placeLabel release];
	[imagePickerButton release];
	[navItem release];
	[imagePreview release];
	[imagePlaceholder release];
	
    [super dealloc];
}


@end
