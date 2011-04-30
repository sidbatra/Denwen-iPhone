//
//  DWProfilePicViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWProfilePicViewController.h"
#import "DWCreationQueue.h"
#import "DWImageView.h"
#import "DWConstants.h"
#import "DWGUIManager.h"
#import "DWMemoryPool.h"
#import "DWSession.h"
#import "DWRequestsManager.h"

static NSString* const kMsgImageUploadErrorTitle			= @"Error";
static NSString* const kMsgImageUploadErrorText				= @"Image uploading failed. Please try again";
static NSString* const kMsgImageUploadErrorCancelButton		= @"OK";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWProfilePicViewController

@synthesize user                    = _user;
@synthesize userProfileTitleView    = _userProfileTitleView;
@synthesize profilePicManager       = _profilePicManager;

//----------------------------------------------------------------------------------------------------
- (id)initWithUser:(DWUser*)user andDelegate:(id)delegate {
    self = [super init];
    
	if (self) {
		self.user           = user;
		_key                = [[NSDate date] timeIntervalSince1970];
        _delegate           = delegate;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageLoaded:) 
													 name:kNImgActualUserImageLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageError:) 
													 name:kNImgActualUserImageError
												   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.user                       = nil;
    self.userProfileTitleView       = nil;
    self.profilePicManager          = nil;
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
	[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.user.largeURL
											 withResourceID:_key
										successNotification:kNImgActualUserImageLoaded
										  errorNotification:kNImgActualUserImageError];
    
    self.navigationItem.titleView           = nil;   	
	self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    
    if ([self.user isCurrentUser])
        self.navigationItem.rightBarButtonItem  = [DWGUIManager cameraNavButton:self];
    else
        self.navigationItem.rightBarButtonItem  = nil;
}

//----------------------------------------------------------------------------------------------------
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollView {
	return ((DWImageView*)self.view).imageView;
}

//----------------------------------------------------------------------------------------------------
- (void)didTapCameraButton:(id)sender event:(id)event {    
    if(!self.profilePicManager)
        self.profilePicManager = [[[DWProfilePicManager alloc] initWithDelegate:self] autorelease];
    
    [self.profilePicManager presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode]; 
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)imageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
    
	if(resourceID == _key) {
		[(DWImageView*)self.view setupImageView:(UIImage*)[info objectForKey:kKeyImage]];
        
        [self.userProfileTitleView showUserStateFor:[self.user fullName] 
                                   andIsCurrentUser:[self.user isCurrentUser]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
    
	if(resourceID == _key) {
        [self.userProfileTitleView showUserStateFor:[self.user fullName] 
                                   andIsCurrentUser:[self.user isCurrentUser]];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWProfilePicManagerDelegate
//----------------------------------------------------------------------------------------------------
- (UIViewController*)requestController {
    return [_delegate requestCustomTabBarController];
}

//----------------------------------------------------------------------------------------------------
- (void)photoPicked:(UIImage*)editedImage {
    [(DWImageView*)self.view setupImageView:editedImage];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark FullScreenMode
//----------------------------------------------------------------------------------------------------
- (void)requiresFullScreenMode {
    
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)willShowOnNav {
    if (!self.userProfileTitleView ) 
        self.userProfileTitleView = [[[DWUserProfileTitleView alloc] 
                                      initWithFrame:CGRectMake(kNavTitleViewX, 0,
                                                               kNavTitleViewWidth,kNavTitleViewHeight) 
                                           delegate:self 
                                          titleMode:kNavStandaloneTitleMode 
                                      andButtonType:kDWButtonTypeStatic] autorelease];
    
    [self.navigationController.navigationBar addSubview:self.userProfileTitleView];  
    [self.userProfileTitleView showProcessingState];
}

@end
