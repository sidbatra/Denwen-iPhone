//
//  DWUserViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUserViewController.h"

static NSInteger const kMessageCellIndex			= 2;


//Declarations for private methods
//
@interface DWUserViewController () 
- (BOOL)loadItems;
- (void)checkCurrentUser;
- (void)displayProfilePicture;
- (void)displayCreatePostFlow;
- (void)addRightBarButtonItem;
- (void)sendUpdateUserRequest:(NSString*)userPhotoFilename;
@end



@implementation DWUserViewController



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithUserID:(int)userID andDelegate:(id)delegate {
	return [self initWithUserID:userID hideBackButton:NO andDelegate:delegate];
}


// Init the view along with its member variables 
//
- (id)initWithUserID:(int)userID hideBackButton:(BOOL)hideBackButton andDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		_userID = userID;
		_isCurrenUserProfile = hideBackButton;
		

		[self checkCurrentUser];
		
	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemCreated:) 
													 name:N_NEW_ITEM_CREATED 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
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


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:_isCurrenUserProfile ? BACK_BUTTON_SELF_TITLE : BACK_BUTTON_TITLE
										 style:UIBarButtonItemStyleBordered
										target:nil
										action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];
	
	[self.refreshHeaderView applyBackgroundImage:nil 
								   withFadeImage:[UIImage imageNamed:USER_VIEW_FADE_IMAGE_NAME]
							 withBackgroundColor:[UIColor colorWithRed:0.6156 green:0.6666 blue:0.7372 alpha:1.0]
	 ];
	
	if(!_isLoadedOnce)
		[self loadItems];
}


// Tests whether the current user (if logged in) is the same as _user
//
- (void)checkCurrentUser {
	_isCurrentUser = [[DWSession sharedDWSession] isActive] && _userID == [DWSession sharedDWSession].currentUser.databaseID;
}


// Display the profile picture of the user
//
- (void)displayProfilePicture {
	if(_user.hasPhoto) {
		DWImageViewController *imageView = [[DWImageViewController alloc] initWithImageURL:_user.largeURL];
		imageView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:imageView animated:YES];
		[imageView release];	
	}
}


// Displays the create place flow
//
- (void)displayCreatePostFlow {
}


// Adds a compose button to the right bar button item
//
- (void)addRightBarButtonItem {
	UIBarButtonItem *newItemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																				   target:self 
																				   action:@selector(didPressCreateNewItem:event:) ];
	self.navigationItem.rightBarButtonItem = newItemButton;
	[newItemButton release];
}


// Users clicks on the create the compose right bar button
//
- (void)didPressCreateNewItem:(id)sender event:(id)event {
	[self displayCreatePostFlow];
}
	


#pragma mark -
#pragma mark NewItemViewControllerDelegate


// Fired when user cancels the new item creation
//
- (void)newItemCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


// Fired when the new has successfully created a new item for this place
//
- (void)newItemCreationFinished {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark NewPlaceViewControllerDelegate

// User cancels the new place creation process
//
- (void)newPlaceCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


// User just finished creating a new place
//
- (void)newPlaceCreated:(DWPlace*)place {
	
	DWPlaceViewController *placeView = [[DWPlaceViewController alloc] initWithPlace:place
																	withNewItemPrompt:YES 
																		  andDelegate:self];
	[self.navigationController pushViewController:placeView animated:NO];
	[placeView release];
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark ItemManager 


// Fetches recent items from places being followed by the current user
//
- (BOOL)loadItems {
	[super loadItems];
	
	[[DWRequestsManager sharedDWRequestsManager] getUserWithID:_userID 
														atPage:_currentPage];
	return YES;
}



// Sends a PUT request to update the picture of the user
//
- (void)sendUpdateUserRequest:(NSString*)userPhotoFilename {
	[[DWRequestsManager sharedDWRequestsManager] updatePhotoForUserWithID:_userID
														withPhotoFilename:userPhotoFilename];
}




#pragma mark -
#pragma mark Notification handlers

- (void)mediumUserImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData && 
	   _tableViewUsage != kTableViewAsProfileMessage) {
		
		return;
	}
	
	NSDictionary *info	= [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _user.databaseID) {
		
		return;
	}
	
	
	NSIndexPath *userIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	DWUserCell *cell = (DWUserCell*)[self.tableView cellForRowAtIndexPath:userIndexPath];
	[cell setMediumPreviewUserImage:[info objectForKey:kKeyImage]];
}




// New item created
//
- (void)newItemCreated:(NSNotification*)notification {
	DWItem *item = (DWItem*)[notification object];
		
	if(_isLoadedOnce && _user == item.user)
		[self addNewItem:item atIndex:1];
}



// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
	
	if(!_userID)
		_userID = [DWSession sharedDWSession].currentUser.databaseID;
	
	[self checkCurrentUser];
	
	
	if(_isCurrentUser) {
		[self addRightBarButtonItem];
		[self.tableView reloadData];
	}
}

- (void)userLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _userID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary *body = [info objectForKey:kKeyBody];
		NSArray *items = [body objectForKey:ITEMS_JSON_KEY];
		[_itemManager populateItems:items withBuffer:(_currentPage==kPagInitialPage) withClear:_isReloading];
		
		
		if(_user)
			[DWMemoryPool removeObject:_user atRow:kMPUsersIndex];
		
		/* Create or fetch the user from the memory pool*/
		NSDictionary *userJSON = [body objectForKey:USER_JSON_KEY];
		_user = (DWUser*)[DWMemoryPool getOrSetObject:userJSON atRow:kMPUsersIndex];			
		
		if(!_isCurrenUserProfile)
			self.title = [_user fullName];
		else
			self.title = [_user firstName];
		
		_isLoadedOnce = YES;
		
		if(_isCurrentUser)
			[self addRightBarButtonItem];
		
		if([_itemManager totalItems]==1 && [[DWSession sharedDWSession] isActive] && [DWSession sharedDWSession].currentUser.databaseID == _user.databaseID) {
			self.messageCellText = USER_SIGNED_IN_NO_ITEMS_MSG;
			_tableViewUsage = kTableViewAsProfileMessage;
		}
		else
			_tableViewUsage = kTableViewAsData;			
	}
	
	[self finishedLoadingItems];	
	[self.tableView reloadData]; 
}


- (void)userError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _userID)
		return;
	
	if(!_isReloading)
		[mbProgressIndicator hideUsingAnimation:YES];
	
	[self finishedLoadingItems];
}	


- (void)userUpdated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _userID)
		return;
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary *body = [info objectForKey:kKeyBody];
		NSDictionary *userJSON = [body objectForKey:USER_JSON_KEY];
		[_user updatePreviewURLs:userJSON];
		[mbProgressIndicator hideUsingAnimation:YES];
	}
}

- (void)userUpdateError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _userID)
		return;
	
	[mbProgressIndicator hideUsingAnimation:YES];
}


- (void)imageUploadDone:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		[self sendUpdateUserRequest:[info objectForKey:kKeyFilename]];
	}
}


- (void)imageUploadError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		[mbProgressIndicator hideUsingAnimation:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"There was an error uploading your image. Please try again."
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}


#pragma mark -
#pragma mark Table view methods

// Calculates the height of cells based on the data within them
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	
	if((_tableViewUsage == kTableViewAsData || _tableViewUsage == kTableViewAsProfileMessage) && indexPath.row == 0)
		height = _isCurrentUser ? FOLLOW_CURRENT_USER_CELL_HEIGHT : FOLLOW_USER_CELL_HEIGHT;
	else
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
	
	
	return height;
}


// Override the cellForRowAtIndexPath method to insert place information in the first cell 
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	
	if((_tableViewUsage == kTableViewAsData || _tableViewUsage == kTableViewAsProfileMessage) && indexPath.row == 0) {
		DWUserCell *cell = (DWUserCell*)[tableView dequeueReusableCellWithIdentifier:USER_CELL_IDENTIFIER];
		
		if (!cell) {
			cell = [[[DWUserCell alloc] initWithStyle:UITableViewCellStyleDefault 
									  reuseIdentifier:USER_CELL_IDENTIFIER
											   withRow:indexPath.row 
											 andTaget:self] 
					autorelease];
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell userName].text = [_user fullName];
		
		//Display the change profile pic image only for the current logged in user
		if(_isCurrentUser) 
			[cell displaySignedInState:_user.hasPhoto];
			
		[_user startMediumPreviewDownload];
		
		//Test if the user image preview got pulled from the cache instantly
		if (_user.mediumPreviewImage)
			[cell setMediumPreviewUserImage:_user.mediumPreviewImage];
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
		
		if(_tableViewUsage == kTableViewAsData && indexPath.row < [_itemManager totalItems])
			[(DWItemFeedCell*)cell disableUserButtons];
	}
	
	return cell;
}



#pragma mark -
#pragma mark Cell Click events



// Handles click event on the table view cell
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if((_tableViewUsage == kTableViewAsData || _tableViewUsage == kTableViewAsProfileMessage) && indexPath.row == 0) {
		
		DWFollowedPlacesViewController *followedView = [[DWFollowedPlacesViewController alloc] initWithDelegate:_delegate 
																								   withUser:_user];
		[self.navigationController pushViewController:followedView animated:YES];
		[followedView release];
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
	
}


// User clicks the place image to change photo
//
- (void)didTapUserMediumImage:(id)sender event:(id)event {
	
	//Display editing options only if the user view belongs to the current users
	//
	if(_isCurrentUser) {
		UIActionSheet *actionSheet = nil;
		
		if(_user.hasPhoto) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
											 cancelButtonTitle:CANCEL_PHOTO_MSG	destructiveButtonTitle:nil
											 otherButtonTitles:BETTER_TAKE_PHOTO_MSG,BETTER_CHOOSE_PHOTO_MSG,nil];
		}
		else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
											 cancelButtonTitle:CANCEL_PHOTO_MSG	destructiveButtonTitle:nil
											 otherButtonTitles:FIRST_TAKE_PHOTO_MSG,FIRST_CHOOSE_PHOTO_MSG,nil];
			
		}
		
		
		
		[actionSheet showInView:self.tabBarController.view];
		[actionSheet release];
	}

}


// User clicks on the new post button within the cell
//
- (void)didTapNewPostButton:(id)sender event:(id)event {
	[self displayCreatePostFlow];
}


// User clicks on the new place button within the ell
///
- (void)didTapNewPlaceButton:(id)sender event:(id)event {
	DWNewPlaceViewController *newPlaceView = [[DWNewPlaceViewController alloc] initWithDelegate:self];
	[self.navigationController presentModalViewController:newPlaceView animated:YES];
	[newPlaceView release];
}



// Handle clicks on the Photo modality selection action sheet
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	//if(buttonIndex == 0) {
	//	[self displayProfilePicture];
	//}
	if(buttonIndex != 2) {
		[DWMemoryPool freeMemory];
		
		UIImagePickerController *imagePickerController = imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;		
		imagePickerController.sourceType =  buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
	}
}	




// Override click on user image to show profile picture
//
- (void)didTapUserImage:(id)sender event:(id)event {
	[self displayProfilePicture];
}



#pragma mark -
#pragma mark UIImagePickerControllerDelegate


// Called when a user chooses a picture from the library of the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
	
	[self dismissModalViewControllerAnimated:YES];
	
	mbProgressIndicator.labelText = @"Loading";
	[mbProgressIndicator showUsingAnimation:YES];
	
	_uploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:image 
																		toFolder:S3_USERS_FOLDER];

	[_user updatePreviewImages:image];
}


// Called when user cancels the photo selection / creation process
//
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}





#pragma mark -
#pragma mark Memory management

//
//
- (void)viewDidUnload {
	[super viewDidUnload];
}

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
	
	if(_user) {
		_user.mediumPreviewImage = nil;
		[DWMemoryPool removeObject:_user atRow:kMPUsersIndex];
	}
	
		
    [super dealloc];
}


@end

