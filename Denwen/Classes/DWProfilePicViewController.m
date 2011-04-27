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
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private Methods
//----------------------------------------------------------------------------------------------------
-(void)presentMediaPickerControllerForPickerMode:(NSInteger)pickerMode {
    [[DWMemoryPool sharedDWMemoryPool] freeMemory];
    
    DWMediaPickerController *picker = [[[DWMediaPickerController alloc] initWithDelegate:self] autorelease];
    [picker prepareForImageWithPickerMode:pickerMode];
    [[_delegate requestCustomTabBarController] presentModalViewController:picker animated:NO];   
}

//----------------------------------------------------------------------------------------------------
- (void)sendUpdateUserRequest:(NSString*)userPhotoFilename {
	[[DWRequestsManager sharedDWRequestsManager] updatePhotoForUserWithID:self.user.databaseID
														withPhotoFilename:userPhotoFilename];
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
    [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];    
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
#pragma mark DWMediaPickerControllerDelegate
//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingImage:(UIImage*)originalImage 
				  andEditedTo:(UIImage*)editedImage {
	
	[[_delegate requestCustomTabBarController] dismissModalViewControllerAnimated:NO];
    
    
    [[DWCreationQueue sharedDWCreationQueue] addNewUpdateUserPhotoToQueueWithUserID:self.user.databaseID
                                                                           andImage:editedImage];
    
	[self.user updatePreviewImages:editedImage];
	[(DWImageView*)self.view setupImageView:editedImage];
}

//----------------------------------------------------------------------------------------------------
- (void)mediaPickerCancelledFromMode:(NSInteger)imagePickerMode {    
    [[_delegate requestCustomTabBarController] dismissModalViewControllerAnimated:NO];  
    
    if (imagePickerMode == kMediaPickerLibraryMode)
        [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
}

//----------------------------------------------------------------------------------------------------
- (void)photoLibraryModeSelected {
    [[_delegate requestCustomTabBarController] dismissModalViewControllerAnimated:NO];
    [self presentMediaPickerControllerForPickerMode:kMediaPickerLibraryMode];
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
