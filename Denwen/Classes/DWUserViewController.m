//
//  DWUserViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWUserViewController.h"
#import "DWRequestsManager.h"
#import "DWGUIManager.h"
#import "DWMemoryPool.h"
#import "DWSession.h"
#import "DWFollowedPlacesViewController.h"

//Cells
#import "DWItemFeedCell.h"
#import "DWMessageCell.h"

static NSInteger const kMessageCellIndex					= 2;
static NSString* const kImgPullToRefreshBackground			= @"userprofilefade.png";
static float	 const kPullToRefreshBackgroundRedValue		= 0.6156;
static float	 const kPullToRefreshBackgroundGreenValue	= 0.6666;
static float	 const kPullToRefreshBackgroundBlueValue	= 0.7372;
static float	 const kPullToRefreshBackgroundAlphaValue	= 1.0;
static NSInteger const kNewItemRowInTableView				= 0;
static NSString* const kMsgCurrentUserNoItems				= @"Everything you post shows up here";
static NSString* const kMsgImageUploadErrorTitle			= @"Error";
static NSString* const kMsgImageUploadErrorText				= @"Image uploading failed. Please try again";
static NSString* const kMsgImageUploadErrorCancelButton		= @"OK";
static NSString* const kUserViewCellIdentifier				= @"UserViewCell";
static NSInteger const kActionSheetCancelIndex				= 2;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWUserViewController

@synthesize user				= _user;
@synthesize userTitleView       = _userTitleView;


//----------------------------------------------------------------------------------------------------
- (id)initWithUser:(DWUser*)theUser 
	   andDelegate:(id)delegate {
	
	self = [super initWithDelegate:delegate];
	
	if (self) {
		
		self.user		= theUser;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemParsed:) 
													 name:kNNewItemParsed 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLoaded:) 
													 name:kNUserLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userError:) 
													 name:kNUserError
												   object:nil];		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userUpdated:) 
													 name:kNUserUpdated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userUpdateError:) 
													 name:kNUserUpdateError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageUploadDone:) 
													 name:kNS3UploadDone
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageUploadError:) 
													 name:kNS3UploadError
												   object:nil];	
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(smallUserImageLoaded:) 
													 name:kNImgSmallUserLoaded
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav-Bar Methods

//----------------------------------------------------------------------------------------------------
- (void)setSmallUserImage:(UIImage*)smallUserImage {
    self.navigationItem.rightBarButtonItem  = [DWGUIManager profilePicButton:self 
                                                         withBackgroundImage:smallUserImage];
}

//----------------------------------------------------------------------------------------------------
- (void)updateUserTitleView {
    [self.userTitleView showUserStateFor:[self.user fullName] 
                       andFollowingCount:[self.user followingCount]];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapSmallUserImage:(id)sender event:(id)event {
    
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    self.navigationItem.titleView           = nil;
                
	if(!_isLoadedOnce)
		[self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
	[super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.user.smallPreviewImage     = nil;
	self.user						= nil;
    self.userTitleView              = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)loadItems {
	[super loadItems];	
	[[DWRequestsManager sharedDWRequestsManager] getUserWithID:self.user.databaseID
														atPage:_currentPage];
}

//----------------------------------------------------------------------------------------------------
- (void)sendUpdateUserRequest:(NSString*)userPhotoFilename {
	[[DWRequestsManager sharedDWRequestsManager] updatePhotoForUserWithID:self.user.databaseID
														withPhotoFilename:userPhotoFilename];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)smallUserImageLoaded:(NSNotification*)notification {
	NSDictionary *info	= [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
    [self setSmallUserImage:[info objectForKey:kKeyImage]];
}

//----------------------------------------------------------------------------------------------------
- (void)newItemParsed:(NSNotification*)notification {
	DWItem *item = (DWItem*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyItem];
		
	if(_isLoadedOnce && self.user == item.user)
		[self addNewItem:item atIndex:kNewItemRowInTableView];
}

//----------------------------------------------------------------------------------------------------
- (void)userLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
		
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		NSDictionary *body	= [info objectForKey:kKeyBody];
		NSArray *items		= [body objectForKey:kKeyItems];
		
		[self.itemManager populateItems:items
							 withBuffer:NO
							  withClear:_isReloading];
		
		[self.user update:[body objectForKey:kKeyUser]];
        [self.user startSmallPreviewDownload];

		_isLoadedOnce = YES;
		
		if([self.itemManager totalItems]==1 && [self.user isCurrentUser]) {
			self.messageCellText	= kMsgCurrentUserNoItems;
			_tableViewUsage			= kTableViewAsProfileMessage;
		}
		else
			_tableViewUsage = kTableViewAsData;			
	}
	
	[self finishedLoadingItems];	
	[self.tableView reloadData]; 
}

//----------------------------------------------------------------------------------------------------
- (void)userError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	[self finishedLoadingItems];
}	

//----------------------------------------------------------------------------------------------------
- (void)userUpdated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		[self.user update:[[info objectForKey:kKeyBody] objectForKey:kKeyUser]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)userUpdateError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
}

//----------------------------------------------------------------------------------------------------
- (void)imageUploadDone:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		[self sendUpdateUserRequest:[info objectForKey:kKeyFilename]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imageUploadError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMsgImageUploadErrorTitle
														message:kMsgImageUploadErrorText
													   delegate:nil 
											  cancelButtonTitle:kMsgImageUploadErrorCancelButton 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UserTitleViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)didTapTitleView {
    DWFollowedPlacesViewController *followedView = [[DWFollowedPlacesViewController alloc] 
                                                    initWithDelegate:_delegate
                                                            withUser:self.user];
    
    [self.navigationController pushViewController:followedView 
                                         animated:YES];
    [followedView release]; 
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)willShowOnNav {
    if (!self.userTitleView)
        self.userTitleView = [[[DWUserTitleView alloc] 
                               initWithFrame:CGRectMake(kNavTitleViewX, 0,
                                                        kNavTitleViewWidth,kNavTitleViewHeight) 
                               delegate:self 
                               titleMode:kNavTitleAndSubtitleMode 
                               andButtonType:kDWButtonTypeStatic] autorelease];
    
    [self.navigationController.navigationBar addSubview:self.userTitleView];
    [self updateUserTitleView];
}


/*
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
- (void)didTapUserMediumImage:(id)sender event:(id)event {	
	if([self.user isCurrentUser]) {
        [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];  
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
    
	_uploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:editedImage
                                                                        toFolder:kS3UsersFolder
                                                              withUploadDelegate:nil];
	
	[self.user updatePreviewImages:editedImage];	
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
}*/


@end

