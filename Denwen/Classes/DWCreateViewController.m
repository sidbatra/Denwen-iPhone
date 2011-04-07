//
//  DWCreateViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreateViewController.h"
#import "DWSession.h"
#import "DWConstants.h"

static NSString* const kTabTitle					= @"Create";
static NSString* const kImgTab						= @"profile.png";
static NSInteger const kTableViewX					= 0;
static NSInteger const kTableViewY					= 32;
static NSInteger const kTableViewWidth				= 320;
static NSInteger const kTableViewHeight				= 270;
static NSInteger const kMaxPlaceNameLength			= 32;
static NSInteger const kMaxPostLength				= 180;

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreateViewController

@synthesize previewImageView	= _previewImageView;
@synthesize transImageView		= _transImageView;
@synthesize placeNameTextField	= _placeNameTextField;
@synthesize dataTextView		= _dataTextView;
@synthesize searchResults		= _searchResults;
@synthesize	mapButton			= _mapButton;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if (self) {
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.dataTextView.placeholderText = @"What's going on here?";
	
	
	CGRect frame					= CGRectMake(kTableViewX,kTableViewY,kTableViewWidth,kTableViewHeight);
	self.searchResults				= [[[DWPlacesSearchResultsViewController alloc] init] autorelease];
	self.searchResults.delegate		= self;
	self.searchResults.view.frame	= frame;
	self.searchResults.view.hidden	= YES;
	
	[self.view addSubview:self.searchResults.view];
	
	[self.placeNameTextField becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.previewImageView		= nil;
	self.transImageView			= nil;
	self.placeNameTextField		= nil;
	self.dataTextView			= nil;
	self.searchResults			= nil;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	if(![self isSelectedTab])
		[super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isSelectedTab {
	return self.tabBarController.selectedViewController == self;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWPlacesSearchResultsViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)placeSelected:(DWPlace *)place {
	self.placeNameTextField.text = place.name;
	[self.dataTextView becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)newPlaceSelected {
	_newPlaceMode			= YES;
	self.mapButton.hidden	= NO;
}


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
    return (newLength > kMaxPostLength) ? NO : YES;
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
- (IBAction)placeNameTextFieldEditingChanged:(id)sender {
	
	if(!_newPlaceMode) {
		self.searchResults.searchText = self.placeNameTextField.text;
		[self.searchResults filterPlacesBySearchText];
	}
}


@end
