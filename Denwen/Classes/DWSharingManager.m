//
//  DWSharingManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSharingManager.h"
#import "DWRequestsManager.h"
#import "DWItem.h"
#import "DWSession.h"
#import "DWConstants.h"


static NSString* const kItemShareURI            = @"/i/";
static NSString* const kSpinnerText             = @"";
static NSInteger const kCancelDefaultIndex      = 3;
static NSInteger const kShareDefaultIndex       = -1;
static NSInteger const kShareFBIndex            = 0;
static NSInteger const kShareTWIndex            = 1;
static NSInteger const kShareEMIndex            = 2;
static NSInteger const kShareSMIndex            = 3;
static NSString* const kMsgFBButton             = @"Facebook";
static NSString* const kMsgTWButton             = @"Twitter";
static NSString* const kMsgEMButton             = @"Email";
static NSString* const kMsgSMButton             = @"SMS";
static NSString* const kMsgCanceButton          = @"Cancel";
static NSInteger const kRecentItemThreshold     = 900;
static NSString* const kMsgEmailBlurb           = @"Download Denwen for iPhone: itun.es/igX5BK\nDenwen helps you show what it's like to be where you work and live.";
static NSString* const kMsgSMSBlurb             = @"Download Denwen for iPhone itun.es/igX5BK";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSharingManager

@synthesize item            = _item;
@synthesize baseController  = _baseController;
@synthesize delegate        = _delegate;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
        _sharingType    = kShareDefaultIndex;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(addressLoaded:) 
													 name:kNAddressLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(addressError:) 
													 name:kNAddressError
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self hideSpinner];

    self.item = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)shareItem:(DWItem*)item 
    viaController:(UIViewController*)baseController {
    
    self.item               = item;
    self.baseController     = baseController;
    _cancelButtonIndex      = kCancelDefaultIndex;
    
    if(!self.item.place.hasAddress) {
        _waitingForAddress = YES;
        [[DWRequestsManager sharedDWRequestsManager] getAddressForPlaceID:self.item.place.databaseID];
    }
    
    
    
    UIActionSheet *actionSheet      = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:kMsgFBButton];
    [actionSheet addButtonWithTitle:kMsgTWButton];
    [actionSheet addButtonWithTitle:kMsgEMButton];
    
    if([MFMessageComposeViewController canSendText]) {
        [actionSheet addButtonWithTitle:kMsgSMButton];
        _cancelButtonIndex++;
    }
    
    [actionSheet addButtonWithTitle:kMsgCanceButton];
        
    [actionSheet setCancelButtonIndex:_cancelButtonIndex];
    [actionSheet showInView:self.baseController.view];
    [actionSheet release];    
}

//----------------------------------------------------------------------------------------------------
- (void)finishedWithSharingUsingText:(NSString*)sharingText {
    [[DWRequestsManager sharedDWRequestsManager] createShareForItemWithID:self.item.databaseID
                                                                 withData:sharingText
                                                                   sentTo:pow(2,_sharingType)];
    [_delegate sharingFinished];
}

//----------------------------------------------------------------------------------------------------
- (void)finishedWithoutSharing {
    [_delegate sharingFinished];
}

//----------------------------------------------------------------------------------------------------
- (void)presentSharingUI {
    
    if(_sharingType == kShareFBIndex) {
        [self shareViaFacebook];
    }
    else if(_sharingType == kShareTWIndex) {
        [self shareViaTwitter];
    }
    else if(_sharingType == kShareEMIndex) {
        [self shareViaEmail];
    }
    else if(_sharingType == _cancelButtonIndex) {
        [self finishedWithoutSharing];
    }
    else if(_sharingType == kShareSMIndex) {
        [self shareViaSMS];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)afterAddressProcessing {
    _waitingForAddress = NO;
    
    if(_sharingType != kShareDefaultIndex) {
        [self hideSpinner];
        [self presentSharingUI];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)displaySpinner {
    
    if([self.baseController respondsToSelector:@selector(displaySpinnerWithText:)]) {
        [self.baseController performSelector:@selector(displaySpinnerWithText:) 
                                  withObject:kSpinnerText];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)hideSpinner {
    
    if([self.baseController respondsToSelector:@selector(hideSpinner)]) {
        [self.baseController performSelector:@selector(hideSpinner)];
    }
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Distributon to different modalities

//----------------------------------------------------------------------------------------------------
- (NSString*)generateSharingPlaceText:(BOOL)withAddress {
    NSString *specificAddressField = [self.item.place displayAddressWithDefautMessage:NO];
    
    return [specificAddressField length] && withAddress ? 
            [NSString stringWithFormat:@"%@ (%@)",self.item.place.name,specificAddressField] : 
            [NSString stringWithString:self.item.place.name];
}

//----------------------------------------------------------------------------------------------------
- (NSString*)generateSharingItemText:(BOOL)withAddress {
    NSString *text          = nil;
    NSString *placeText     = [self generateSharingPlaceText:withAddress];
    BOOL isRecentItem       = [self.item createdTimeAgoStamp] <= kRecentItemThreshold;
    BOOL isOwnItem          = [self.item.user isCurrentUser];
    
    
    if(isOwnItem && isRecentItem) {
        text = [NSString stringWithFormat:@"Just posted at %@",
                placeText];
    }
    else if(isOwnItem) {
        text = [NSString stringWithFormat:@"My post at %@",
                placeText];
    }
    else if(isRecentItem) {
        text = [NSString stringWithFormat:@"Just saw this at %@",
                placeText];
    }
    else {
        text = [NSString stringWithFormat:@"Saw this at %@",
                placeText];
    }
    
    return text;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)generateSharingURL:(BOOL)addProtocol {
    
    NSString *url = nil;
    
    if(addProtocol) {
        url = [NSString stringWithFormat:@"%@%@%@%@",
                kDenwenProtocol,
                kDenwenServer,
                kItemShareURI,
                self.item.hashedID];   
    }
    else {
        url = [NSString stringWithFormat:@"%@%@%@",
                kDenwenServer,
                kItemShareURI,
                self.item.hashedID];
    }
    
    return url;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)generateSharingText:(BOOL)addProtocol 
                     withAddress:(BOOL)withAddress {
    
    NSString *url           = [self generateSharingURL:addProtocol];
    NSString *itemText      = [self generateSharingItemText:withAddress];
    
    return [NSString stringWithFormat:@"%@ on Denwen %@ ",itemText,url];
}

//----------------------------------------------------------------------------------------------------
- (void)shareViaFacebook {
    DWShareItemViewController *shareItemView    = [[[DWShareItemViewController alloc] initWithItem:self.item] autorelease];
    shareItemView.delegate                      = self;
    
    [shareItemView prepareForFacebook];
    
    [self.baseController presentModalViewController:shareItemView
                                           animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)shareViaTwitter {
    DWShareItemViewController *shareItemView    = [[[DWShareItemViewController alloc] initWithItem:self.item] autorelease];
    shareItemView.delegate                      = self;
    
    [shareItemView prepareForTwitter];

    [self.baseController presentModalViewController:shareItemView
                                           animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)shareViaEmail {
    
    MFMailComposeViewController *mailView   = [[[MFMailComposeViewController alloc] init] autorelease];
    mailView.mailComposeDelegate            = self;
    
    [mailView setSubject:[self generateSharingItemText:NO]];
    [mailView setMessageBody:[NSString stringWithFormat:@"%@\n--\n%@",[self generateSharingText:YES 
                                                                                        withAddress:YES],kMsgEmailBlurb]
                      isHTML:NO];
    
    [self.baseController presentModalViewController:mailView
                                           animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)shareViaSMS {

    MFMessageComposeViewController *smsView = [[[MFMessageComposeViewController alloc] init] autorelease];
    smsView.messageComposeDelegate          = self;
    
    [smsView setBody:[NSString stringWithFormat:@"%@\n--\n%@",[self generateSharingText:YES 
                                                                            withAddress:YES],kMsgSMSBlurb]];
    
    [self.baseController presentModalViewController:smsView
                                           animated:YES];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWShareItemViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (NSString*)sharingFBText {
    return [self generateSharingText:YES 
                         withAddress:YES];
}

//----------------------------------------------------------------------------------------------------
- (NSString*)sharingTWText {
    return [self generateSharingText:YES 
                         withAddress:YES];
}

//----------------------------------------------------------------------------------------------------
- (NSString*)sharingItemURL {
    return [self generateSharingURL:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)sharingCancelled {
    [self.baseController dismissModalViewControllerAnimated:YES];
    [self finishedWithoutSharing];
}

//----------------------------------------------------------------------------------------------------
- (void)sharingFinishedWithText:(NSString *)text {
    [self.baseController dismissModalViewControllerAnimated:YES];
    [self finishedWithSharingUsingText:text];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MFMessageComposeViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    [self.baseController dismissModalViewControllerAnimated:YES];
    
    if(result == MessageComposeResultSent)
        [self finishedWithSharingUsingText:kEmptyString];
    else
        [self finishedWithoutSharing];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    [self.baseController dismissModalViewControllerAnimated:YES];
    
    if(result == MFMailComposeResultSaved || result == MFMailComposeResultSent)
        [self finishedWithSharingUsingText:kEmptyString];
    else
        [self finishedWithoutSharing];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIActionSheetDelegate

//----------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
    
    _sharingType = buttonIndex;
    
    if(_waitingForAddress)
        [self displaySpinner];
    else
        [self presentSharingUI];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)addressLoaded:(NSNotification*)notification {
   
    NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.item.place.databaseID)
		return;
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *addresses = [[info objectForKey:kKeyBody] objectForKey:kKeyAddresses];
        
        [self.item.place updateAddress:[addresses lastObject]];
    }
    
    [self afterAddressProcessing];
}

//----------------------------------------------------------------------------------------------------
- (void)addressError:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.item.place.databaseID)
		return;
    
    [self afterAddressProcessing];
}

@end
