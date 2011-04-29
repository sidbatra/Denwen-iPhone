//
//  DWCreateViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreateViewController.h"
#import "DWChooseLocationViewController.h"
#import "DWMemoryPool.h"
#import "DWCreationQueue.h"
#import "DWSession.h"
#import "DWConstants.h"

static NSString* const kTabTitle							= @"Create";
static NSString* const kImgTab								= @"profile.png";
static NSString* const kMsgDataTextViewPlaceholder			= @"What's the latest?";
static NSInteger const kTableViewX							= 0;
static NSInteger const kTableViewY							= 44;
static NSInteger const kTableViewWidth						= 320;
static NSInteger const kTableViewHeight						= 200;
static NSInteger const kMaxPlaceNameLength					= 32;
static NSInteger const kMaxPostLength						= 140;
static NSString* const kMsgImageUploadErrorTitle			= @"Error";
static NSString* const kMsgImageUploadErrorText				= @"Image uploading failed. Please try again";
static NSString* const kMsgImageUploadErrorCancelButton		= @"OK";
static NSInteger const kActionSheetCancelIndex				= 2;
static NSString* const kImgLightBackgroundButton			= @"button_gray_light.png";
static NSString* const kImgDarkBackgroundCancelButton		= @"button_gray_dark_cancel.png";
static NSString* const kImgDarkBackgroundCancelButtonActive	= @"button_gray_dark_cancel_active.png";
static NSString* const kImgLightCameraButton				= @"camera_white.png";
static NSString* const kImgCheckedLightCameraButton			= @"camera_white_checked.png";
static NSString* const kImgCheckedBlueCameraButton			= @"camera_blue_checked.png";
static NSString* const kImgCheckedLightVideoButton			= @"video_white_checked.png";
static NSString* const kImgCheckedBlueVideoButton			= @"video_blue_checked.png";
static NSString* const kImgLightMapButton					= @"pointer_white.png";
static NSString* const kImgDarkMapButton					= @"pointer_gray_light.png";
static NSString* const kMsgMissingFieldsTitle				= @"Missing Fields";
static NSString* const kMsgPlaceMissing						= @"Select an existing place or create a new one";
static NSString* const kMsgDataMissing						= @"Write a post or attach an image or video";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreateViewController

@synthesize atLabel				= _atLabel;
@synthesize previewImageView	= _previewImageView;
@synthesize transImageView		= _transImageView;
@synthesize placeNameTextField	= _placeNameTextField;
@synthesize dataTextView		= _dataTextView;
@synthesize searchResults		= _searchResults;
@synthesize	mapButton			= _mapButton;
@synthesize	cancelButton		= _cancelButton;
@synthesize doneButton			= _doneButton;
@synthesize cameraButton		= _cameraButton;
@synthesize coverLabel			= _coverLabel;
@synthesize topCoverLabel		= _topCoverLabel;

@synthesize selectedPlace		= _selectedPlace;
@synthesize newPlaceLocation	= _newPlaceLocation;
@synthesize cameraImage			= _cameraImage;
@synthesize videoURL			= _videoURL;
@synthesize videoOrientation	= _videoOrientation;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if (self) {
		_attachmentType = kAttachmentImage;
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
	
	self.atLabel				= nil;
	self.previewImageView		= nil;
	self.transImageView			= nil;
	self.placeNameTextField		= nil;
	self.dataTextView			= nil;
	self.mapButton				= nil;
	self.cancelButton			= nil;
	self.doneButton				= nil;
	self.cameraButton			= nil;
	self.coverLabel				= nil;
	self.topCoverLabel			= nil;
	
	self.searchResults			= nil;
	self.selectedPlace			= nil;
	self.newPlaceLocation		= nil;
	self.cameraImage			= nil;
	self.videoURL				= nil;
	self.videoOrientation		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
		
	self.newPlaceLocation				= [[DWSession sharedDWSession] location];
	self.dataTextView.placeholderText	= kMsgDataTextViewPlaceholder;
	
	CGRect frame						= CGRectMake(kTableViewX,kTableViewY,kTableViewWidth,kTableViewHeight);
	self.searchResults					= [[[DWPlacesSearchResultsViewController alloc] init] autorelease];
	self.searchResults.delegate			= self;
	self.searchResults.view.frame		= frame;
	self.searchResults.view.hidden		= YES;
	
	[self.view addSubview:self.searchResults.view];
	
	[self.placeNameTextField becomeFirstResponder];
	
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];	
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	/**
	 * Commented out to prevent reloading upon a
	 * low memory warning
	 */
	//[super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
	//[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
}

//----------------------------------------------------------------------------------------------------
- (void)displayMediaUI {
	/**
	 * Revamp the entire UI when media is selected
	 */
	self.coverLabel.backgroundColor		= [UIColor blackColor];
	self.topCoverLabel.hidden			= NO;
	
	self.previewImageView.hidden		= NO;
	self.transImageView.hidden			= NO;
	
	[self.cancelButton setBackgroundImage:[UIImage imageNamed:kImgDarkBackgroundCancelButton] 
								 forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:[UIImage imageNamed:kImgDarkBackgroundCancelButtonActive]
								 forState:UIControlStateHighlighted];
	
	[self.mapButton setBackgroundImage:[UIImage imageNamed:kImgLightMapButton]
								 forState:UIControlStateNormal];
	
	[self.cameraButton setBackgroundImage:[UIImage imageNamed:kImgLightCameraButton]
								 forState:UIControlStateNormal];

	self.dataTextView.placeholderColor		= [UIColor clearColor];
	[self.dataTextView setNeedsDisplay];
	
	
	self.placeNameTextField.textColor				= [UIColor whiteColor];
	self.dataTextView.textColor						= [UIColor whiteColor];
	self.atLabel.textColor							= [UIColor whiteColor];
}

//----------------------------------------------------------------------------------------------------
- (void)displayNormalUI {
	
	self.coverLabel.backgroundColor		= [UIColor whiteColor];
	self.topCoverLabel.hidden			= YES;
	
	self.previewImageView.hidden		= YES;
	self.transImageView.hidden			= YES;
	
	[self.mapButton setBackgroundImage:[UIImage imageNamed:kImgDarkMapButton]
							  forState:UIControlStateNormal];
	
	self.placeNameTextField.textColor	= [UIColor colorWithRed:.498 green:.498 blue:.498 alpha:1.0];		
	self.atLabel.textColor				= [UIColor colorWithRed:0.7019 green:0.7019 blue:0.7019 alpha:1.0];
}

//----------------------------------------------------------------------------------------------------
- (void)enterNewPlaceMode {
    _newPlaceMode			= YES;
	self.mapButton.hidden	= NO;   
    self.selectedPlace      = nil;
}

//----------------------------------------------------------------------------------------------------
- (void)exitNewPlaceMode {
    _newPlaceMode			= NO;
	self.mapButton.hidden	= YES;
}

//----------------------------------------------------------------------------------------------------
-(BOOL)isValidPost {
	
	BOOL status = YES;
	
	if(!(self.selectedPlace || (_newPlaceMode && self.placeNameTextField.text.length > 0))) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgMissingFieldsTitle
														message:kMsgPlaceMissing
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		status = NO;
	}
	
	if(status && !(self.dataTextView.text.length > 0 || self.cameraImage || self.videoURL)) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgMissingFieldsTitle
														message:kMsgDataMissing
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		status = NO;
	}

	return status;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWPlacesSearchResultsViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)placeSelected:(DWPlace *)place {
	self.selectedPlace				= place;
	self.placeNameTextField.text	= self.selectedPlace.name;
	
	if(_isMediaSelected)
		[self displayMediaUI];
	
	[self.dataTextView becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)newPlaceSelected {
	
	if(_isMediaSelected)
		[self displayMediaUI];
	
	[self enterNewPlaceMode];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isNewPlaceMode {
    return _newPlaceMode;
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isPlaceSelected {
    return self.selectedPlace ? YES : NO;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITextFieldDelegate

//----------------------------------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
	
	NSUInteger newLength = [self.placeNameTextField.text length] + [string length] - range.length;
    return (newLength > kMaxPlaceNameLength) ? NO : YES;
}

//----------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if(textField == self.placeNameTextField && _newPlaceMode) {
		[self.placeNameTextField resignFirstResponder];
		[self.dataTextView becomeFirstResponder];
	}

	return NO;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITextViewDelegate

//----------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text{
	
	NSUInteger newLength = [self.dataTextView.text length] + [text length] - range.length;
    return (newLength > kMaxPostLength) || [text isEqualToString:@"\n"] ? NO : YES;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
-(void)presentMediaPickerControllerForPickerMode:(NSInteger)pickerMode {
    [[DWMemoryPool sharedDWMemoryPool] freeMemory];
    
    DWMediaPickerController *picker = [[[DWMediaPickerController alloc] initWithDelegate:self] autorelease];
    [picker prepareForMediaWithPickerMode:pickerMode];
    [self presentModalViewController:picker animated:NO];   
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)cameraButtonClicked:(id)sender {
    [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
}

//----------------------------------------------------------------------------------------------------
- (void)mapButtonClicked:(id)sender {
	
	/**
	 * Update to latest location
	 */
	self.newPlaceLocation = [[DWSession sharedDWSession] location];
	
	DWChooseLocationViewController *chooseLocationView	= [[DWChooseLocationViewController alloc] initWithLocation:self.newPlaceLocation
																									   andDelegate:self];
	chooseLocationView.modalTransitionStyle				= UIModalTransitionStyleCoverVertical;
	
	[self presentModalViewController:chooseLocationView 
							animated:NO];
	
	[chooseLocationView release];
}

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
	
	if(![self isValidPost])
		return;
	
	if(_newPlaceMode) {
		
		if(_attachmentType == kAttachmentImage) {
			
			[[DWCreationQueue sharedDWCreationQueue] addNewPostToQueueWithData:self.dataTextView.text
														   withAttachmentImage:self.cameraImage
																   toPlaceName:self.placeNameTextField.text
																	atLocation:self.newPlaceLocation];
		}
		else if(_attachmentType == kAttachmentVideo) {
			
			[[DWCreationQueue sharedDWCreationQueue] addNewPostToQueueWithData:self.dataTextView.text
																  withVideoURL:self.videoURL
																 atOrientation:self.videoOrientation
																   toPlaceName:self.placeNameTextField.text
																	atLocation:self.newPlaceLocation];
		}
	}
	else {
		
		if(_attachmentType == kAttachmentImage) {
			
			[[DWCreationQueue sharedDWCreationQueue] addNewPostToQueueWithData:self.dataTextView.text
														   withAttachmentImage:self.cameraImage
																	 toPlaceID:self.selectedPlace.databaseID];
		}
		else if(_attachmentType == kAttachmentVideo) {			
			
			[[DWCreationQueue sharedDWCreationQueue] addNewPostToQueueWithData:self.dataTextView.text
																  withVideoURL:self.videoURL
																 atOrientation:self.videoOrientation
																	 toPlaceID:self.selectedPlace.databaseID];
		}

		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNRequestTabBarIndexChange
															object:nil
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	[NSNumber numberWithInt:kTabBarFeedIndex],kKeyTabIndex,
                                                                    [NSNumber numberWithBool:YES],kKeyPopAll,
																	nil]];
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:NO];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)placeNameTextFieldEditingChanged:(id)sender {
	
	if(_newPlaceMode && [self.placeNameTextField.text isEqualToString:kEmptyString])
        [self exitNewPlaceMode];
    else if(_newPlaceMode)
        return;
    
    if(self.selectedPlace && ![self.selectedPlace.name isEqualToString:self.placeNameTextField.text])
        self.selectedPlace = nil;
		
    if(_isMediaSelected)
        self.placeNameTextField.text.length > 0 ? [self displayNormalUI] : [self displayMediaUI];
    
        
    self.searchResults.searchText = self.placeNameTextField.text;
    [self.searchResults filterPlacesBySearchText];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWMediaPickerControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingImage:(UIImage*)originalImage 
				  andEditedTo:(UIImage*)editedImage {
		
	_attachmentType		= kAttachmentImage;
	_isMediaSelected	= YES;
	
	/**
	 * Free memory from a previously selected video
	 */
	self.videoURL			= nil;
	self.videoOrientation	= nil;
	
	[self displayMediaUI];
	
	self.cameraImage			= editedImage;
	self.previewImageView.image = editedImage;
	
	[self dismissModalViewControllerAnimated:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingVideoAtURL:(NSURL*)theVideoURL
				   withOrientation:(NSString*)orientation
						andPreview:(UIImage*)image {
	
	_attachmentType		= kAttachmentVideo;
	_isMediaSelected	= YES;

	/**
	 * Free memory from a previously selected image
	 */
	self.cameraImage = nil;
	
	[self displayMediaUI];
	
	self.videoURL			= theVideoURL;
	self.videoOrientation	= orientation;	
	
	self.previewImageView.image = image;
		
	[self dismissModalViewControllerAnimated:NO];
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
#pragma mark DWChooseLocationViewControllerDeleagate
//----------------------------------------------------------------------------------------------------
- (void)chooseLocationFinishedWithLocation:(CLLocation*)location {
	self.newPlaceLocation = location;
	
	[self dismissModalViewControllerAnimated:NO];
}


@end
