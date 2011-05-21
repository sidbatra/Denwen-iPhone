//
//  DWSharingManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSharingManager.h"
#import "DWRequestsManager.h"
#import "DWItem.h"
#import "DWSession.h"
#import "DWConstants.h"

#define kShareButtonTitles      @"Facebook",@"Twitter",@"Email",@"SMS",nil

static NSString* const kItemShareURI            = @"/i/";
static NSString* const kSpinnerText             = @"";
static NSString* const kShareCancelTitle        = @"Cancel";
static NSInteger const kShareDefaultIndex       = -1;
static NSInteger const kShareFBIndex            = 0;
static NSInteger const kShareTWIndex            = 1;
static NSInteger const kShareEMIndex            = 2;
static NSInteger const kShareSMIndex            = 3;
static NSInteger const kShareCancelIndex        = 4;
static NSInteger const kRecentItemThreshold     = 900;
static NSString* const kMsgEmailBlurb           = @"Denwen is a simple way to create places that mean something to you — where you work, where you live,anywhere you spend time. \n\n Download Denwen from the Apple App Store - http://j.mp/denwen";



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
    
    if(!self.item.place.hasAddress) {
        _waitingForAddress = YES;
        [[DWRequestsManager sharedDWRequestsManager] getAddressForPlaceID:self.item.place.databaseID];
    }
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:kShareCancelTitle
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:kShareButtonTitles];
    [actionSheet showInView:self.baseController.view];
    [actionSheet release];    
}

//----------------------------------------------------------------------------------------------------
- (void)presentSharingUI {
    
    if(_sharingType == kShareFBIndex) {
        NSLog(@"facebook");
    }
    else if(_sharingType == kShareTWIndex) {
        NSLog(@"twitter"); 
    }
    else if(_sharingType == kShareEMIndex) {
        [self shareViaEmail];
    }
    else if(_sharingType == kShareSMIndex) {
        NSLog(@"sms");
    }
    else if(_sharingType == kShareCancelIndex) {
        NSLog(@"cancel");
        [_delegate sharingFinished];
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
- (NSString*)generateSharingPlaceText {
    NSString *specificAddressField = [self.item.place mostSpecificAddressString];
    
    return [specificAddressField length] ? 
            [NSString stringWithFormat:@"%@ (%@)",self.item.place.name,specificAddressField] : 
            [NSString stringWithString:self.item.place.name];
}

//----------------------------------------------------------------------------------------------------
- (NSString*)generateSharingText {
    
    NSString *text          = nil;
    NSString *placeText     = [self generateSharingPlaceText];
    NSString *urlText       = [NSString stringWithFormat:@"on Denwen %@%@%@%@",
                                kDenwenProtocol,
                                kDenwenServer,
                                kItemShareURI,
                                self.item.hashedID];
    BOOL isRecentItem       = [self.item createdTimeAgoStamp] <= kRecentItemThreshold;
    BOOL isOwnItem          = [self.item.user isCurrentUser];
    
    
    if(isOwnItem && isRecentItem) {
        text = [NSString stringWithFormat:@"Just posted at %@ %@",
                    placeText,
                    urlText];
    }
    else if(isOwnItem) {
        text = [NSString stringWithFormat:@"My post at %@ %@",
                placeText,
                urlText];
    }
    else if(isRecentItem) {
        text = [NSString stringWithFormat:@"Just saw this at %@ %@",
                placeText,
                urlText];
    }
    else {
        text = [NSString stringWithFormat:@"Saw this at %@ %@",
                placeText,
                urlText];
    }
    
    return text;
}

//----------------------------------------------------------------------------------------------------
- (void)shareViaEmail {
    
    MFMailComposeViewController *mailView   = [[[MFMailComposeViewController alloc] init] autorelease];
    mailView.mailComposeDelegate            = self;
    
    [mailView setSubject:[NSString stringWithFormat:@"%@ shared a post with you",[DWSession sharedDWSession].currentUser.firstName]];    
    [mailView setMessageBody:[NSString stringWithFormat:@"%@ \n\n %@",[self generateSharingText],kMsgEmailBlurb]
                      isHTML:NO];
    
    [self.baseController presentModalViewController:mailView
                                           animated:YES];
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
    
    if(result == MFMailComposeResultSaved || result == MFMailComposeResultSent) {
    }
    else {
    }
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
