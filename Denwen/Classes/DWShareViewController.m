//
//  DWShareViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWShareViewController.h"
#import "DWConstants.h"

@interface DWShareViewController()
- (void)freezeUI;
- (void)unfreezeUI;

- (void)testEndOfSharing;

- (void)twitterSwitchedOn;
- (void)facebookSwitchedOn;
- (void)updateUIState;
@end

@implementation DWShareViewController


@synthesize twitterSwitch,facebookSwitch,textView,doneButton,sharingOptionsContainerView,backgroundImageView,navigationBar,hashedLink;


//=============================================================================================================================
#pragma mark -
#pragma mark View lifecycle


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate andPlace:(DWPlace*)place {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
	
		_twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_twitterEngine.consumerKey    = TWITTER_OAUTH_CONSUMER_KEY;
		_twitterEngine.consumerSecret = TWITTER_OAUTH_CONSUMER_SECRET;	
	
		_facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID];
		
		_place = place;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(facebookURLOpened:) 
													 name:N_FACEBOOK_URL_OPENED
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(largeImageLoaded:) 
													 name:kNImgLargePlaceLoaded
												   object:nil];
		
	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationBar.topItem.title = _place.name;
	
	//rounded corners and border customization
	[[sharingOptionsContainerView layer] setCornerRadius:5.0f];
	[[sharingOptionsContainerView layer] setBorderWidth:0.0f];
	[[sharingOptionsContainerView layer] setMasksToBounds:YES];
	[[sharingOptionsContainerView layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
	
	[_place startLargePreviewDownload];
	
	if(_place.largePreviewImage)
		backgroundImageView.image = _place.largePreviewImage;
	else
		backgroundImageView.image = [UIImage imageNamed:kImgGenericPlaceHolder];
	
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];
	
	textView.text = [NSString stringWithFormat:@"This is %@ ",_place.name];
	hashedLink.text = [NSString stringWithFormat:@"http://denwen.com/p/%@",_place.hashedID];
	
	[textView becomeFirstResponder];
	
	if([DWSession sharedDWSession].currentUser.twitterOAuthData) {
		twitterSwitch.on = YES;
		[self twitterSwitchedOn];
	}
	
	if([DWSession sharedDWSession].currentUser.facebookAccessToken) {
		facebookSwitch.on = YES;
		_facebook.accessToken = [DWSession sharedDWSession].currentUser.facebookAccessToken;
		_facebook.expirationDate = [NSDate distantFuture];
		[self facebookSwitchedOn];
	}
	
	[self updateUIState];
}


// Limit the number of characters in the textView
//
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
	NSUInteger newLength = [theTextView.text length] + [text length] - range.length;
    return (newLength > (MAX_SHARE_DATA_LENGTH - hashedLink.text.length)) ? NO : YES;
}


// Tests whether the delegate for finishing sharing should be fired
//
- (void)testEndOfSharing {
	if( (!twitterSwitch.on || _twitterRequestDone) && (!facebookSwitch.on || _facebookRequestDone) ) {
		NSInteger sentTo = twitterSwitch.on * pow(2,0) + facebookSwitch.on * pow(2,1);
		[_delegate shareViewFinished:[NSString stringWithString:textView.text] sentTo:sentTo];
	}
}
	   

// Modifies the UI state on changes to switches
//
- (void)updateUIState {
	if(twitterSwitch.on || facebookSwitch.on)
		doneButton.enabled = YES;
	else
		doneButton.enabled = NO;
}


// Freeze the UI while sharing is underway
//
- (void)freezeUI {
	[textView resignFirstResponder];
	
	mbProgressIndicator.labelText = @"Posting...";
	[mbProgressIndicator showUsingAnimation:YES];
}


// Unfreeze the UI
//
- (void)unfreezeUI {	
	[mbProgressIndicator hideUsingAnimation:YES];
	
	[textView becomeFirstResponder];
}


// Fired when twitter is switched on
//
- (void)twitterSwitchedOn {
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_twitterEngine delegate:self];
	
	if (controller)
		[self presentModalViewController:controller animated:YES];
}


// Fired when the Twitter Connect Modal view is cancelled
//
- (void)OAuthTwitterControllerCanceled:(id)sender {
	twitterSwitch.on = NO;
	[self updateUIState];
}


// Fired when user clicks the denied button
//
- (void)OAuthTwitterControllerFailed:(id)sender {
	twitterSwitch.on = NO;
	[self updateUIState];
}


// Fired when facebook is switched on
//
- (void)facebookSwitchedOn {
}



//=============================================================================================================================
#pragma mark -
#pragma mark IB Events


// User clicks the cancel button
//
- (void)cancelButtonClicked:(id)sender {
	[_delegate shareViewCancelled];
}


// User clicks the share button
//
- (void)doneButtonClicked:(id)sender {
	
	NSString *fullText = [[NSString alloc] initWithFormat:@"%@ %@",self.textView.text,self.hashedLink.text];
	NSString *photoURL = [_place hasPhoto] ? _place.largeURL : @"";
	NSString *placeTitle = [[NSString alloc] initWithFormat:@"This is %@",_place.name];
	
	if(twitterSwitch.on && [DWSession sharedDWSession].currentUser.twitterOAuthData)
		[_twitterEngine sendUpdate:fullText];
	
	
	if(facebookSwitch.on && [DWSession sharedDWSession].currentUser.facebookAccessToken) {
		NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   fullText,@"message",
									   placeTitle,@"name",
									   @"  ", @"description",
									   @"denwen.com", @"caption",
									   self.hashedLink.text, @"link",
									   photoURL, @"picture",
									   nil];
		
		[_facebook requestWithGraphPath:@"/me/feed"   
							  andParams:params
						  andHttpMethod:@"POST"
							andDelegate:self];
	}
	
	[placeTitle release];
	[fullText release];
	
	[self freezeUI];
}


// Fired when the value of the twitterSwitch changes
//
- (void)twitterSwitchValueChanged:(id)sender {
	if(twitterSwitch.on)
		[self twitterSwitchedOn];
	
	[self updateUIState];
}


// Fired when the value of the facebookSwitch changes
//
- (void)facebookSwitchValueChanged:(id)sender {
	if(facebookSwitch.on) {
		if(![DWSession sharedDWSession].currentUser.facebookAccessToken) {
			[self.textView resignFirstResponder];
			[_facebook authorize:[NSArray arrayWithObjects:@"offline_access", @"publish_stream",nil] delegate:self];
		}
		
		[self facebookSwitchedOn];
	}
	
	[self updateUIState];
}



//=============================================================================================================================
#pragma mark -
#pragma mark Notification handlers


// Fired when a URL matching the URL scheme is opened by the app
//
- (void)facebookURLOpened:(NSNotification*)notification {
	[_facebook handleOpenURL:(NSURL*)[notification object]];
}

- (void)largeImageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	if(resourceID != _place.databaseID)
		return;
	
	backgroundImageView.image = [info objectForKey:kKeyImage];
}



//=============================================================================================================================
#pragma mark -
#pragma mark FBSessionDelegate


// Called when the user has logged into facebook successfully
//
- (void)fbDidLogin {
	[self.textView becomeFirstResponder];
	[[DWSession sharedDWSession].currentUser storeFacebookToken:_facebook.accessToken];
	[[DWRequestsManager sharedDWRequestsManager] updateFacebookTokenForCurrentUser:_facebook.accessToken];
}


// Called when the user cancelled the authorization dialog
//
-(void)fbDidNotLogin:(BOOL)cancelled {
	[self.textView becomeFirstResponder];
	facebookSwitch.on = NO;
	[self updateUIState];
}



//=============================================================================================================================
#pragma mark -
#pragma mark FBReqestDelegate

// Called when the Facebook API request has returned a response. This callback
// gives you access to the raw response. It's called before
// (void)request:(FBRequest *)request didLoad:(id)result,
// which is passed the parsed response object.
//
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
}

// Called when a request returns and its response has been parsed into
// an object. The resulting object may be a dictionary, an array, a string,
// or a number, depending on the format of the API response. If you need access
// to the raw response, use:
//
// (void)request:(FBRequest *)request
//      didReceiveResponse:(NSURLResponse *)response
//
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	
	_facebookRequestDone = YES;
	[self testEndOfSharing];
};


// Called when an error prevents the Facebook API request from completing
// successfully.
//
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	//[error localizedDescription]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Problem connecting to Facebook, please try again"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	
	[self unfreezeUI];
	
};



//=============================================================================================================================
#pragma mark -
#pragma mark SA_OAuthTwitterEngineDelegate


// Store the Twitter OAuth data as a member variable and on disk
//
- (void)storeCachedTwitterOAuthData:(NSString *) data forUsername:(NSString *)username {
	[[DWSession sharedDWSession].currentUser storeTwitterData:data];
	[[DWRequestsManager sharedDWRequestsManager] updateTwitterDataForCurrentUser:data];
}


// Return the twitterOAuthData member variable
//
- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *) username {
	return [DWSession sharedDWSession].currentUser.twitterOAuthData;
}


//=============================================================================================================================
#pragma mark -
#pragma mark TwitterEngineDelegate


// Fired when the twitterEngine request succeeds
//
- (void)requestSucceeded: (NSString *) requestIdentifier {
	_twitterRequestDone = YES;
	[self testEndOfSharing];
}


// Fired when there is an error in a twitterEngine request
//
- (void)requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Problem connecting to Twitter, please try again"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];

	
	[self unfreezeUI];
}



//=============================================================================================================================
#pragma mark -
#pragma mark Memory Management

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// The usual viewDidUnload
- (void)viewDidUnload {
    [super viewDidUnload];
}


// The usual dealloc
//
- (void)dealloc {
	_delegate = nil;
	
	self.twitterSwitch = nil;
	self.facebookSwitch = nil;
	self.textView = nil;
	self.doneButton = nil;
	self.backgroundImageView = nil;
	self.navigationBar = nil;
	self.hashedLink = nil;
	
	[_twitterEngine release];
	[_facebook release];
	
    [super dealloc];
}


@end
