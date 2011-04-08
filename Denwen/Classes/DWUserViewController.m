//
//  DWUserViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWUserViewController.h"
#import "DWRequestsManager.h"
#import "DWMemoryPool.h"
#import "DWFollowedPlacesViewController.h"
#import "DWSession.h"

//Cells
#import "DWUserCell.h"
#import "DWItemFeedCell.h"
#import "DWMessageCell.h"

static NSInteger const kMessageCellIndex					= 2;
static NSString* const kImgPullToRefreshBackground			= @"userprofilefade.png";
static float	 const kPullToRefreshBackgroundRedValue		= 0.6156;
static float	 const kPullToRefreshBackgroundGreenValue	= 0.6666;
static float	 const kPullToRefreshBackgroundBlueValue	= 0.7372;
static float	 const kPullToRefreshBackgroundAlphaValue	= 1.0;
static NSInteger const kNewItemRowInTableView				= 1;
static NSString* const kMsgCurrentUserNoItems				= @"Everything you post shows up here";
static NSString* const kMsgImageUploadErrorTitle			= @"Error";
static NSString* const kMsgImageUploadErrorText				= @"Image uploading failed. Please try again";
static NSString* const kMsgImageUploadErrorCancelButton		= @"OK";
static NSString* const kUserViewCellIdentifier				= @"UserViewCell";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWUserViewController

@synthesize user				= _user;
@synthesize mediaPicker			= _mediaPicker;
@synthesize mbProgressIndicator	= _mbProgressIndicator;

//----------------------------------------------------------------------------------------------------
- (id)initWithUser:(DWUser*)theUser 
	   andDelegate:(id)delegate {
	
	self = [super initWithDelegate:delegate];
	
	if (self) {
		
		self.user		= theUser;
		_tableViewUsage = kTableViewAsData;
		
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
												 selector:@selector(mediumUserImageLoaded:) 
													 name:kNImgMediumUserLoaded
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:kGenericBackButtonTitle
																			  style:UIBarButtonItemStyleBordered
																			 target:nil
																			 action:nil] autorelease];
	
	self.mbProgressIndicator = [[[MBProgressHUD alloc] initWithView:self.navigationController.view] autorelease];
	[self.navigationController.view addSubview:self.mbProgressIndicator];
	
	[self.refreshHeaderView applyBackgroundImage:nil 
								   withFadeImage:[UIImage imageNamed:kImgPullToRefreshBackground]
							 withBackgroundColor:[UIColor colorWithRed:kPullToRefreshBackgroundRedValue
																 green:kPullToRefreshBackgroundGreenValue
																  blue:kPullToRefreshBackgroundBlueValue
																 alpha:kPullToRefreshBackgroundAlphaValue]];
	self.title = [self.user fullName];

	if(!_isLoadedOnce)
		[self loadItems];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.mbProgressIndicator = nil;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}


//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.user.mediumPreviewImage	= nil;
	self.user						= nil;
	self.mediaPicker				= nil;
	self.mbProgressIndicator		= nil;
	
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
- (void)mediumUserImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData && 
	   _tableViewUsage != kTableViewAsProfileMessage) {
		
		return;
	}
	
	NSDictionary *info	= [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID) {
		
		return;
	}
	
	
	NSIndexPath *userIndexPath = [NSIndexPath indexPathForRow:0
													inSection:0];
	
	DWUserCell *cell = (DWUserCell*)[self.tableView cellForRowAtIndexPath:userIndexPath];
	[cell setMediumPreviewUserImage:[info objectForKey:kKeyImage]];
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
							 withBuffer:(_currentPage==kPagInitialPage)
							  withClear:_isReloading];
		
		[self.user update:[body objectForKey:kKeyUser]];
		
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
	
	if(!_isReloading)
		[self.mbProgressIndicator hideUsingAnimation:YES];
	
	[self finishedLoadingItems];
}	

//----------------------------------------------------------------------------------------------------
- (void)userUpdated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		[self.user update:[[info objectForKey:kKeyBody] objectForKey:kKeyUser]];
		[self.mbProgressIndicator hideUsingAnimation:YES];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)userUpdateError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	[self.mbProgressIndicator hideUsingAnimation:YES];
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
		[self.mbProgressIndicator hideUsingAnimation:YES];
		
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
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	
	if((_tableViewUsage == kTableViewAsData || _tableViewUsage == kTableViewAsProfileMessage) && 
		indexPath.row == 0)
		
		height = kUserViewCellHeight;
	else
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
	
	
	return height;
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;	
	
	if((_tableViewUsage == kTableViewAsData || _tableViewUsage == kTableViewAsProfileMessage) && 
		indexPath.row == 0) {
		
		DWUserCell *cell = (DWUserCell*)[tableView dequeueReusableCellWithIdentifier:kUserViewCellIdentifier];
		
		if (!cell) {
			cell = [[[DWUserCell alloc] initWithStyle:UITableViewCellStyleDefault 
									  reuseIdentifier:kUserViewCellIdentifier
											   withRow:indexPath.row 
											 andTaget:self] autorelease];
		}
		
		cell.selectionStyle		= UITableViewCellSelectionStyleNone;
		[cell userName].text	= [self.user fullName];
		
		if([self.user isCurrentUser]) 
			[cell displaySignedInState:self.user.hasPhoto];
			
		[self.user startMediumPreviewDownload];
		
		if (self.user.mediumPreviewImage)
			[cell setMediumPreviewUserImage:self.user.mediumPreviewImage];
		else
			[cell setMediumPreviewUserImage:[UIImage imageNamed:kImgGenericPlaceHolder]];
		
		return cell;
	}
	else {
		cell = [super tableView:(tableView) cellForRowAtIndexPath:indexPath];
		
		//Override position of the message cell
		if(_tableViewUsage == kTableViewAsProfileMessage && indexPath.row == kMessageCellIndex) {
			((DWMessageCell*)cell).textLabel.text = @"";
			((DWMessageCell*)cell).customTextLabel.hidden = NO;
			((DWMessageCell*)cell).customTextLabel.text = self.messageCellText;
		}
		
		if(_tableViewUsage == kTableViewAsData && indexPath.row < [self.itemManager totalItems])
			[(DWItemFeedCell*)cell disableUserButtons];
	}
	
	return cell;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if((_tableViewUsage == kTableViewAsData || _tableViewUsage == kTableViewAsProfileMessage) && 
		indexPath.row == 0) {
		
		DWFollowedPlacesViewController *followedView = [[DWFollowedPlacesViewController alloc] initWithDelegate:_delegate 
																								   withUser:self.user];
		[self.navigationController pushViewController:followedView animated:YES];
		[followedView release];
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)didTapUserMediumImage:(id)sender event:(id)event {
	
	/**
	 * Display editing options only if the user view belongs to the current users
	 */
	if([self.user isCurrentUser]) {
		
		UIActionSheet *actionSheet = nil;
		
		if(self.user.hasPhoto) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
													  delegate:self 
											 cancelButtonTitle:kMsgCancelPhoto	
										destructiveButtonTitle:nil
											 otherButtonTitles:kMsgTakeBetterPhoto,kMsgChooseBetterPhoto,nil];
		}
		else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
													  delegate:self 
											 cancelButtonTitle:kMsgCancelPhoto	
										destructiveButtonTitle:nil
											 otherButtonTitles:kMsgTakeFirstPhoto,kMsgChooseFirstPhoto,nil];
		}
		
		[actionSheet showInView:self.tabBarController.view];
		[actionSheet release];
	}

}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIActionSheetDelegate

//----------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	if(buttonIndex != 2) {
		[[DWMemoryPool sharedDWMemoryPool]  freeMemory];
		
		self.mediaPicker = [[[DWMediaPicker alloc] initWithDelegate:self] autorelease];
		
		[self.mediaPicker prepareForImageWithPickerMode:buttonIndex == 0 ? kMediaPickerCaptureMode : kMediaPickerLibraryMode
											 withEditing:YES];
		
		[self presentModalViewController:self.mediaPicker.imagePickerController
								animated:YES];
	}
}	
	

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWMediaPickerDelegate

//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingImage:(UIImage*)originalImage andEditedTo:(UIImage*)editedImage {
	
	[self dismissModalViewControllerAnimated:YES];
	
	self.mediaPicker = nil;
	
	self.mbProgressIndicator.labelText = @"Loading";
	[self.mbProgressIndicator showUsingAnimation:YES];
	
	_uploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:editedImage
																		toFolder:kS3UsersFolder];
	
	[self.user updatePreviewImages:editedImage];	
}

//----------------------------------------------------------------------------------------------------
- (void)mediaPickerCancelled {
	[self dismissModalViewControllerAnimated:YES];
	
	self.mediaPicker = nil;
}


@end

