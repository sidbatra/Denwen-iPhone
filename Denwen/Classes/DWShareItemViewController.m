//
//  DWShareItemViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWShareItemViewController.h"
#import "DWConstants.h"
#import "DWItem.h"

static CGFloat   const kAlphaThresholdForMOG        = 0.001;
static NSInteger const kMaxTwitterDataLength        = 140;
static NSString* const kMsgErrorAlertTitle          = @"Low connectivity";
static NSString* const kMsgFacebookError            = @"Can't connect to Facebook";
static NSString* const kMsgTwitterError             = @"Can't connect to Twitter";
static NSString* const kMsgCancelTitle              = @"OK";
static NSString* const kImgLightCancelButton		= @"button_gray_light_cancel.png";
static NSString* const kImgLightCancelButtonActive	= @"button_gray_light_cancel_active.png";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWShareItemViewController

@synthesize item                = _item;
@synthesize itemURL             = _itemURL;
@synthesize sharingText         = _sharingText;
@synthesize facebookConnect     = _facebookConnect;
@synthesize twitterConnect      = _twitterConnect;
@synthesize delegate            = _delegate;
@synthesize previewImageView    = _previewImageView;
@synthesize transImageView      = _transImageView;
@synthesize dataTextView        = _dataTextView;
@synthesize cancelButton        = _cancelButton;
@synthesize doneButton          = _doneButton;
@synthesize coverLabel          = _coverLabel;

//----------------------------------------------------------------------------------------------------
- (id)initWithItem:(DWItem*)theItem {
    self = [super init];
    
    if (self) {
        self.item   = theItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemAttachmentLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
    
    self.item               = nil;
    self.itemURL            = nil;
    self.sharingText        = nil;
    self.facebookConnect    = nil;
    self.twitterConnect     = nil;
    self.previewImageView   = nil;
    self.transImageView     = nil;
    self.dataTextView       = nil;
    self.cancelButton       = nil;
    self.doneButton         = nil;
    self.coverLabel         = nil;
    
    [super dealloc];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.item.attachment) {
        [self.item startRemoteImagesDownload];
        
        if(self.item.attachment.previewImage)
            self.previewImageView.image = self.item.attachment.previewImage;
    }
    else
        [self displayTextUI];
    
    
    self.dataTextView.text  = self.sharingText;
    [self.dataTextView becomeFirstResponder];
    
    
    mbProgressIndicator         = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    mbProgressIndicator.frame   = CGRectMake(mbProgressIndicator.frame.origin.x,
                                             mbProgressIndicator.frame.origin.y-20,
                                             mbProgressIndicator.frame.size.width,
                                             mbProgressIndicator.frame.size.height);
	[self.view addSubview:mbProgressIndicator];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

//----------------------------------------------------------------------------------------------------
- (void)displayTextUI {
	
	self.coverLabel.backgroundColor		= [UIColor whiteColor];
	
	self.previewImageView.hidden		= YES;
	self.transImageView.hidden			= YES;
    
    self.dataTextView.textColor         = [UIColor colorWithRed:0.498
                                                          green:0.498 
                                                           blue:0.498
                                                          alpha:1.0];
         
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:kImgLightCancelButton] 
								 forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:[UIImage imageNamed:kImgLightCancelButtonActive]
								 forState:UIControlStateHighlighted];
}

//----------------------------------------------------------------------------------------------------
- (void)freezeUI {
    if(mbProgressIndicator.alpha < kAlphaThresholdForMOG)
        [mbProgressIndicator showUsingAnimation:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)unfreezeUI {
    [mbProgressIndicator hideUsingAnimation:YES];
    [self.dataTextView becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForFacebookWithText:(NSString*)text 
                            andURL:(NSString*)url {
    
    _sharingDestination             = kSharingDestinationFacebook;
    self.itemURL                    = url;
    self.sharingText                = text;
    
    self.facebookConnect            = [[[DWFacebookConnect alloc] init] autorelease];
    self.facebookConnect.delegate   = self;
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForTwitterWithText:(NSString *)text {
    
    _sharingDestination             = kSharingDestinationTwitter;
    self.sharingText                = text;
    
    self.twitterConnect             = [[[DWTwitterConnect alloc] init] autorelease];
    self.twitterConnect.delegate    = self;
}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITextViewDelegate

//----------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text{
	
	NSUInteger newLength = [self.dataTextView.text length] + [text length] - range.length;
    
    return (_sharingDestination == kSharingDestinationTwitter && newLength > kMaxTwitterDataLength) 
                || [text isEqualToString:@"\n"] ? NO : YES;
}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)itemAttachmentLoaded:(NSNotification*)notification {
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
    if(self.item.attachment.databaseID != resourceID)
        return;
    
	self.previewImageView.image = [info objectForKey:kKeyImage];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWFacebookConnectDelegate

//----------------------------------------------------------------------------------------------------
- (void)fbAuthenticated {
    [self.dataTextView becomeFirstResponder];
    [self freezeUI];
        
    [self.facebookConnect createWallPostWithMessage:self.dataTextView.text
                                               name:self.item.place.name
                                        description:@" " 
                                            caption:@"denwen.com"
                                               link:self.itemURL 
                                         pictureURL:self.item.attachment ? 
                                                        self.item.attachment.previewURL : 
                                                        kEmptyString];
}

//----------------------------------------------------------------------------------------------------
- (void)fbAuthenticating {
    [self.dataTextView resignFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)fbAuthenticationFailed {
    [self unfreezeUI];
}

//----------------------------------------------------------------------------------------------------
- (void)fbSharingDone {
    [_delegate sharingFinishedWithText:self.dataTextView.text];
}

//----------------------------------------------------------------------------------------------------
- (void)fbSharingFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorAlertTitle
													message:kMsgFacebookError
												   delegate:nil 
										  cancelButtonTitle:kMsgCancelTitle
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	
	[self unfreezeUI];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTwitterConnectDelegate

//----------------------------------------------------------------------------------------------------
- (void)twAuthenticated {
    [self freezeUI];
    
    [self.twitterConnect createTweetWithText:self.dataTextView.text];
}

//----------------------------------------------------------------------------------------------------
- (void)twAuthenticating {
    [self freezeUI];
}

//----------------------------------------------------------------------------------------------------
- (void)twAuthenticationFailed {
    [self unfreezeUI];
}

//----------------------------------------------------------------------------------------------------
- (void)twSharingDone {
    [_delegate sharingFinishedWithText:self.dataTextView.text];
}

//----------------------------------------------------------------------------------------------------
- (void)twSharingFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgErrorAlertTitle
													message:kMsgTwitterError
												   delegate:nil 
										  cancelButtonTitle:kMsgCancelTitle
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	
	[self unfreezeUI];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
    [_delegate sharingCancelled];
}

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
    
    if(_sharingDestination == kSharingDestinationFacebook) 
        [self.facebookConnect authenticate];
    else if(_sharingDestination == kSharingDestinationTwitter)
        [self.twitterConnect authenticate];
}	


@end
