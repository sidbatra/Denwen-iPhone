//
//  DWCreateViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreateViewController.h"
#import "DWSession.h"
#import "DWConstants.h"

static NSString* const kTabTitle					= @"Create";
static NSString* const kImgTab						= @"profile.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreateViewController

@synthesize previewImageView	= _previewImageView;
@synthesize transImageView		= _transImageView;
@synthesize placeNameTextField	= _placeNameTextField;
@synthesize dataTextView		= _dataTextView;

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
	
	[self.placeNameTextField becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.previewImageView		= nil;
	self.transImageView			= nil;
	self.placeNameTextField		= nil;
	self.dataTextView			= nil;
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
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:kNRequestTabBarIndexChange 
														object:nil
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSNumber numberWithInt:[DWSession sharedDWSession].previouslySelectedTab],kKeyTabIndex,
																nil]];
}


@end
