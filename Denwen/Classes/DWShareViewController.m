//
//  DWShareViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWShareViewController.h"
#import "DWRequestsManager.h"
#import "DWSession.h"
#import "DWConstants.h"

static NSInteger const kMaxShareDataLength	= 140;
static NSString* const kMsgErrorAlertTitle	= @"Error";
static NSString* const kMsgFacebookError	= @"Error connecting to Facebook, please try again";
static NSString* const kMsgTwitterError		= @"Error connecting to Twitter, please try again";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWShareViewController

@synthesize place							= _place;

@synthesize twitterEngine					= _twitterEngine;
@synthesize facebook						= _facebook;

@synthesize sharingOptionsContainerView		= _sharingOptionsContainerView;
@synthesize twitterSwitch					= _twitterSwitch;
@synthesize facebookSwitch					= _facebookSwitch;
@synthesize textView						= _textView;
@synthesize doneButton						= _doneButton;
@synthesize backgroundImageView				= _backgroundImageView;
@synthesize navigationBar					= _navigationBar;
@synthesize hashedLink						= _hashedLink;

@synthesize mbProgressIndicator				= _mbProgressIndicator;

//----------------------------------------------------------------------------------------------------
- (id)initWithPlace:(DWPlace*)thePlace
		andDelegate:(id)delegate {

	self = [super init];
	
	if(self) {
		_delegate = delegate;
	
		self.twitterEngine = [[[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self] autorelease];
		self.twitterEngine.consumerKey    = kTwitterOAuthConsumerKey;
		self.twitterEngine.consumerSecret = kTwitterOAuthConsumerSecret;	
	
		self.facebook	= [[[Facebook alloc] initWithAppId:kFacebookAppID] autorelease];
		self.place		= thePlace;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(facebookURLOpened:) 
													 name:kNFacebookURLOpened
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_delegate							= nil;
	
	self.place							= nil;
	
	self.twitterEngine					= nil;
	self.facebook						= nil;
	
	self.sharingOptionsContainerView	= nil;
	self.twitterSwitch					= nil;
	self.facebookSwitch					= nil;
	self.textView						= nil;
	self.doneButton						= nil;
	self.backgroundImageView			= nil;
	self.navigationBar					= nil;
	self.hashedLink						= nil;
	
	self.mbProgressIndicator			= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)updateUIState {
	if(self.twitterSwitch.on || self.facebookSwitch.on)
		self.doneButton.enabled = YES;
	else
		self.doneButton.enabled = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)twitterSwitchedOn {
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:self.twitterEngine 
																								   delegate:self];
	if (controller)
		[self presentModalViewController:controller animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)facebookSwitchedOn {
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationBar.topItem.title = self.place.name;
		
	[[self.sharingOptionsContainerView layer] setCornerRadius:5.0f];
	[[self.sharingOptionsContainerView layer] setBorderWidth:0.0f];
	[[self.sharingOptionsContainerView layer] setMasksToBounds:YES];
	[[self.sharingOptionsContainerView layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
		
	self.backgroundImageView.image = [UIImage imageNamed:kImgGenericPlaceHolder];
	
	self.mbProgressIndicator = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
	[self.view addSubview:self.mbProgressIndicator];
	
	self.textView.text	= [NSString stringWithFormat:@"This is %@ in %@ ",self.place.name,[self.place displayAddress]];
	self.hashedLink.text = [NSString stringWithFormat:@"http://%@/p/%@",kDenwenServer,self.place.hashedID];
	
	[self.textView becomeFirstResponder];
	
	/**
	 * Test if twitter connect has already been performed
	 */
	if([DWSession sharedDWSession].currentUser.twitterOAuthData) {
		self.twitterSwitch.on = YES;
		
		[self twitterSwitchedOn];
	}
	
	/**
	 * Test if facebook connect has already been performed
	 */
	if([DWSession sharedDWSession].currentUser.facebookAccessToken) {
		self.facebookSwitch.on				= YES;
		self.facebook.accessToken		= [DWSession sharedDWSession].currentUser.facebookAccessToken;
		self.facebook.expirationDate	= [NSDate distantFuture];
		
		[self facebookSwitchedOn];
	}
	
	[self updateUIState];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range 
												   replacementText:(NSString *)text {
	
	NSUInteger newLength = [theTextView.text length] + [text length] - range.length;
    return (newLength > (kMaxShareDataLength - self.hashedLink.text.length)) ? NO : YES;
}

//----------------------------------------------------------------------------------------------------
- (void)testEndOfSharing {
	if( (!self.twitterSwitch.on || _twitterRequestDone) && (!self.facebookSwitch.on || _facebookRequestDone) ) {
		NSInteger sentTo = self.twitterSwitch.on * pow(2,0) + self.facebookSwitch.on * pow(2,1);
		
		[_delegate shareViewFinished:[NSString stringWithString:self.textView.text] 
							  sentTo:sentTo];
	}
}


//----------------------------------------------------------------------------------------------------
- (void)freezeUI {
	[self.textView resignFirstResponder];
	
	self.mbProgressIndicator.labelText = @"Posting...";
	[self.mbProgressIndicator showUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)unfreezeUI {	
	[self.mbProgressIndicator hideUsingAnimation:YES];
	
	[self.textView becomeFirstResponder];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
	[_delegate shareViewCancelled];
}

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
	
	NSString *fullText		= [NSString stringWithFormat:@"%@ %@",self.textView.text,self.hashedLink.text];
	NSString *photoURL		= @"";//[self.place hasPhoto] ? self.place.largeURL : @"";
	NSString *placeTitle	= [NSString stringWithFormat:@"This is %@",self.place.name];
	
	if(self.twitterSwitch.on && [DWSession sharedDWSession].currentUser.twitterOAuthData) {
		[self.twitterEngine sendUpdate:fullText];
	}

	if(self.facebookSwitch.on && [DWSession sharedDWSession].currentUser.facebookAccessToken) {
		NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   fullText				,@"message",
									   placeTitle			,@"name",
									   @"  "				,@"description",
									   @"denwen.com"		,@"caption",
									   self.hashedLink.text	,@"link",
									   photoURL				,@"picture",
									   nil];
		
		[self.facebook requestWithGraphPath:@"/me/feed"   
							  andParams:params
						  andHttpMethod:@"POST"
							andDelegate:self];
	}
	
	[self freezeUI];
}

//----------------------------------------------------------------------------------------------------
- (void)twitterSwitchValueChanged:(id)sender {
	if(self.twitterSwitch.on)
		[self twitterSwitchedOn];
	
	[self updateUIState];
}

//----------------------------------------------------------------------------------------------------
- (void)facebookSwitchValueChanged:(id)sender {
	if(self.facebookSwitch.on) {
		if(![DWSession sharedDWSession].currentUser.facebookAccessToken) {
			[self.textView resignFirstResponder];
			[self.facebook authorize:[NSArray arrayWithObjects:@"offline_access", @"publish_stream",nil] delegate:self];
		}
		
		[self facebookSwitchedOn];
	}
	
	[self updateUIState];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)facebookURLOpened:(NSNotification*)notification {
	[self.facebook handleOpenURL:(NSURL*)[notification object]];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark FBSessionDelegate

//----------------------------------------------------------------------------------------------------
- (void)fbDidLogin {
	[self.textView becomeFirstResponder];
	[[DWSession sharedDWSession].currentUser storeFacebookToken:self.facebook.accessToken];
	[[DWRequestsManager sharedDWRequestsManager] updateFacebookTokenForCurrentUser:self.facebook.accessToken];
}

//----------------------------------------------------------------------------------------------------
-(void)fbDidNotLogin:(BOOL)cancelled {
	[self.textView becomeFirstResponder];
	self.facebookSwitch.on = NO;
	[self updateUIState];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark FBReqestDelegate

//----------------------------------------------------------------------------------------------------
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	/**
	 * Called when the Facebook API request has returned a response. This callback
	 * gives you access to the raw response. It's called before
	 * (void)request:(FBRequest *)request didLoad:(id)result,
	 * which is passed the parsed response object.
	 */
}

//----------------------------------------------------------------------------------------------------
- (void)request:(FBRequest *)request didLoad:(id)result {
	/** 
	 * Called when a request returns and its response has been parsed into
	 * an object. The resulting object may be a dictionary, an array, a string,
	 * or a number, depending on the format of the API response. If you need access
	 * to the raw response, use:
	 *
	 * (void)request:(FBRequest *)request
	 *      didReceiveResponse:(NSURLResponse *)response
	 */
	
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	
	_facebookRequestDone = YES;
	[self testEndOfSharing];
}


//----------------------------------------------------------------------------------------------------
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorAlertTitle
													message:kMsgFacebookError
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	
	[self unfreezeUI];
};


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark SA_OAuthTwitterEngineDelegate

//----------------------------------------------------------------------------------------------------
- (void)storeCachedTwitterOAuthData:(NSString *) data forUsername:(NSString *)username {
	[[DWSession sharedDWSession].currentUser storeTwitterData:data];
	[[DWRequestsManager sharedDWRequestsManager] updateTwitterDataForCurrentUser:data];
}

//----------------------------------------------------------------------------------------------------
- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *) username {
	return [DWSession sharedDWSession].currentUser.twitterOAuthData;
}

//----------------------------------------------------------------------------------------------------
- (void)OAuthTwitterControllerCanceled:(id)sender {
	self.twitterSwitch.on = NO;
	[self updateUIState];
}

//----------------------------------------------------------------------------------------------------
- (void)OAuthTwitterControllerFailed:(id)sender {
	self.twitterSwitch.on = NO;
	[self updateUIState];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark TwitterEngineDelegate

//----------------------------------------------------------------------------------------------------
- (void)requestSucceeded: (NSString *) requestIdentifier {
	_twitterRequestDone = YES;
	[self testEndOfSharing];
}

//----------------------------------------------------------------------------------------------------
- (void)requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorAlertTitle
													message:kMsgTwitterError
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];

	
	[self unfreezeUI];
}

@end
