//
//  DWUserViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUserViewController.h"


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
		_updateUserRequestManager = [[DWRequestManager alloc] initWithDelegate:self andInstanceID:1];
		_s3Uploader = [[DWS3Uploader alloc] initWithDelegate:self];
		_isCurrenUserProfile = hideBackButton;
		

		[self checkCurrentUser];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumUserPreviewDone:) 
													 name:N_MEDIUM_USER_PREVIEW_DONE
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemCreated:) 
													 name:N_NEW_ITEM_CREATED 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
												   object:nil];
	}
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	
	uiShell = _isCurrenUserProfile ? (UIViewController*)_delegate : self;

	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:_isCurrenUserProfile ? BACK_BUTTON_SELF_TITLE : BACK_BUTTON_TITLE
										 style:UIBarButtonItemStyleBordered
										target:nil
										action:nil];
	uiShell.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:uiShell.navigationController.view];
	[uiShell.navigationController.view addSubview:mbProgressIndicator];
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
	_isCurrentUser = [DWSessionManager isSessionActive] && _userID == currentUser.databaseID;
}


// Display the profile picture of the user
//
- (void)displayProfilePicture {
	if(_user.hasPhoto) {
		DWImageViewController *imageView = [[DWImageViewController alloc] initWithImageURL:_user.largeURL];
		imageView.hidesBottomBarWhenPushed = YES;
		[uiShell.navigationController pushViewController:imageView animated:YES];
		[imageView release];	
	}
}


// Displays the create place flow
//
- (void)displayCreatePostFlow {
	DWSelectPlaceViewController *selectPlaceView = [[DWSelectPlaceViewController alloc] initWithDelegate:self];																																							
	
	UINavigationController *selectPlaceNav = [[UINavigationController alloc] initWithRootViewController:selectPlaceView];
	[selectPlaceView release];
	
	[uiShell.navigationController presentModalViewController:selectPlaceNav animated:YES];
	[selectPlaceNav release];		
}


// Adds a compose button to the right bar button item
//
- (void)addRightBarButtonItem {
	UIBarButtonItem *newItemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																				   target:self 
																				   action:@selector(didPressCreateNewItem:event:) ];
	uiShell.navigationItem.rightBarButtonItem = newItemButton;
	[newItemButton release];
}


// Users clicks on the create the compose right bar button
//
- (void)didPressCreateNewItem:(id)sender event:(id)event {
	[self displayCreatePostFlow];
}
	

#pragma mark -
#pragma mark SelectPlaceViewControllerDelegate 


// User cancels the select place view
//
- (void)selectPlaceCancelled {
	[uiShell.navigationController dismissModalViewControllerAnimated:YES];
}


// User selects a place to post to
//
- (void)selectPlaceFinished:(NSString*)placeName andPlaceID:(NSInteger)placeID {
	[uiShell.navigationController dismissModalViewControllerAnimated:NO];
	
	DWNewItemViewController *newItemView = [[DWNewItemViewController alloc] initWithDelegate:self 
																			   withPlaceName:placeName
																				 withPlaceID:placeID
																			   withForcePost:NO];
	[uiShell.navigationController presentModalViewController:newItemView animated:NO];
	[newItemView release];
}



#pragma mark -
#pragma mark NewItemViewControllerDelegate


// Fired when user cancels the new item creation
//
- (void)newItemCancelled {
	[uiShell.navigationController dismissModalViewControllerAnimated:YES];
}


// Fired when the new has successfully created a new item for this place
//
- (void)newItemCreationFinished {
	[uiShell.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark NewPlaceViewControllerDelegate

// User cancels the new place creation process
//
- (void)newPlaceCancelled {
	[uiShell.navigationController dismissModalViewControllerAnimated:YES];
}


// User just finished creating a new place
//
- (void)newPlaceCreated:(NSString*)placeHashedID {
	
	DWPlaceViewController *placeView = [[DWPlaceViewController alloc] initWithPlaceID:placeHashedID
																	withNewItemPrompt:YES 
																		  andDelegate:self];
	[uiShell.navigationController pushViewController:placeView animated:NO];
	[placeView release];
	
	[uiShell.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark ItemManager 


// Fetches recent items from places being followed by the current user
//
- (BOOL)loadItems {
	[super loadItems];
	

	NSString *urlString = nil;
	
	if([DWSessionManager isSessionActive])
		urlString = [[NSString alloc] initWithFormat:@"%@%d.json?page=%d&email=%@&password=%@&ff=mobile",
							   USER_SHOW_URI,
							   _userID,
							   _currentPage,
							   currentUser.email,
							   currentUser.encryptedPassword
							   ];
	else
		urlString = [[NSString alloc] initWithFormat:@"%@%d.json?page=%d&ff=mobile",
							   USER_SHOW_URI,
							   _userID,
							   _currentPage
							   ];
	
	[_requestManager sendGetRequest:urlString];
	[urlString release];
	
	return YES;
}



// Sends a PUT request to update the picture of the user
//
- (void)sendUpdateUserRequest:(NSString*)userPhotoFilename {

	NSString *urlString = [[NSString alloc] initWithFormat:@"%@%d.json?photo_filename=%@&email=%@&password=%@&ff=mobile",
						   USER_SHOW_URI,
						   _user.databaseID,
						   userPhotoFilename,
						   currentUser.email,
						   currentUser.encryptedPassword];
	
	[_updateUserRequestManager sendPutRequest:urlString withParams:@""];
	
	[urlString release];
}



#pragma mark -
#pragma mark DWRequestManagerDelegate


// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if(instanceID == 0 ) { // user show response
		
		if([status isEqualToString:SUCCESS_STATUS]) {
			
			NSArray *items = [body objectForKey:ITEMS_JSON_KEY];
			[_itemManager populateItems:items withBuffer:(_currentPage==INITIAL_PAGE_FOR_REQUESTS) withClear:_reloading];

			
			if(_user)
				[DWMemoryPool removeObject:_user atRow:USERS_INDEX];
			
			/* Create or fetch the user from the memory pool*/
			NSDictionary *userJSON = [body objectForKey:USER_JSON_KEY];
			_user = (DWUser*)[DWMemoryPool getOrSetObject:userJSON atRow:USERS_INDEX];			
			
			if(!_isCurrenUserProfile)
				uiShell.title = [_user fullName];
			else
				uiShell.title = [_user firstName];

			_isLoadedOnce = YES;
			
			if(_isCurrentUser)
				[self addRightBarButtonItem];
						
			if([_itemManager totalItems]==1 && [DWSessionManager isSessionActive] && currentUser.databaseID == _user.databaseID) {
				self.messageCellText = USER_SIGNED_IN_NO_ITEMS_MSG;
				_tableViewUsage = TABLE_VIEW_AS_PROFILE_MESSAGE;
			}
			else
			   _tableViewUsage = TABLE_VIEW_AS_DATA;			
		}
		else {
			
		}
		
		[self finishedLoadingItems];	
		[self.tableView reloadData];  
	}
	else if(instanceID == 1) { // user update response
		
		if([status isEqualToString:SUCCESS_STATUS]) {
			NSDictionary *userJSON = [body objectForKey:USER_JSON_KEY];
			[_user updatePreviewURLs:userJSON];
			[mbProgressIndicator hideUsingAnimation:YES];
		}
		else {
			
		}

	}
			
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	if(!_reloading)
		[mbProgressIndicator hideUsingAnimation:YES];
	
	[self finishedLoadingItems];
}



#pragma mark -
#pragma mark Notification handlers

// Fired when a place has downloaded a medium preview image
//
- (void)mediumUserPreviewDone:(NSNotification*)notification {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA && _tableViewUsage != TABLE_VIEW_AS_PROFILE_MESSAGE)
		return;
	
	DWUser *userWithImage = (DWUser*)[notification object];
	
	if(_user == userWithImage) {
		NSIndexPath *userIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		
		DWUserCell *cell = (DWUserCell*)[self.tableView cellForRowAtIndexPath:userIndexPath];
		[cell setMediumPreviewUserImage:userWithImage.mediumPreviewImage];
	}	
	
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
		_userID = currentUser.databaseID;
	
	[self checkCurrentUser];
	
	
	if(_isCurrentUser) {
		[self addRightBarButtonItem];
		[self.tableView reloadData];
	}
}



#pragma mark -
#pragma mark Table view methods

// Calculates the height of cells based on the data within them
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	
	if((_tableViewUsage == TABLE_VIEW_AS_DATA || _tableViewUsage == TABLE_VIEW_AS_PROFILE_MESSAGE) && indexPath.row == 0)
		height = _isCurrentUser ? FOLLOW_CURRENT_USER_CELL_HEIGHT : FOLLOW_USER_CELL_HEIGHT;
	else
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
	
	
	return height;
}


// Override the cellForRowAtIndexPath method to insert place information in the first cell 
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	
	if((_tableViewUsage == TABLE_VIEW_AS_DATA || _tableViewUsage == TABLE_VIEW_AS_PROFILE_MESSAGE) && indexPath.row == 0) {
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
			[cell setMediumPreviewUserImage:[UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME]];
		
		return cell;
	}
	else {
		cell = [super tableView:(tableView) cellForRowAtIndexPath:indexPath];
		
		//Override position of the message cell
		if(_tableViewUsage == TABLE_VIEW_AS_PROFILE_MESSAGE && indexPath.row == MESSAGE_CELL_INDEX) {
			((DWMessageCell*)cell).textLabel.text = @"";
			((DWMessageCell*)cell).customTextLabel.hidden = NO;
			((DWMessageCell*)cell).customTextLabel.text = self.messageCellText;
		}
		
		if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row < [_itemManager totalItems])
			[(DWItemFeedCell*)cell disableUserButtons];
	}
	
	return cell;
}



#pragma mark -
#pragma mark Cell Click events



// Handles click event on the table view cell
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if((_tableViewUsage == TABLE_VIEW_AS_DATA || _tableViewUsage == TABLE_VIEW_AS_PROFILE_MESSAGE) && indexPath.row == 0) {
		DWFollowedPlacesViewController *followedView = [[DWFollowedPlacesViewController alloc] initWithDelegate:_delegate 
																								   withUserName:_user.firstName
																									  andUserID:_userID
														];
		[uiShell.navigationController pushViewController:followedView animated:YES];
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
		
		
		
		[actionSheet showInView:uiShell.tabBarController.view];
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
	[uiShell.navigationController presentModalViewController:newPlaceView animated:YES];
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
		[uiShell presentModalViewController:imagePickerController animated:YES];
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
	
	[uiShell dismissModalViewControllerAnimated:YES];
	
	mbProgressIndicator.labelText = @"Loading";
	[mbProgressIndicator showUsingAnimation:YES];
	
	[_s3Uploader uploadImage:image toFolder:S3_USERS_FOLDER];
	[_user updatePreviewImages:image];
}


// Called when user cancels the photo selection / creation process
//
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[uiShell dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark S3 Uploader Delegate methods


// Media has been successfully uploaded to S3
//
- (void)finishedUploadingMedia:(NSString*)filename {
	//Use the updated photo filename to update the database entry for the user
	//
	[self sendUpdateUserRequest:filename];
}


// An error happened while uploading media to S3
//
- (void)errorUploadingMedia:(NSError*)error {
	[mbProgressIndicator hideUsingAnimation:YES];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"There was an error uploading your image. Please try again."
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
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
		[DWMemoryPool removeObject:_user atRow:USERS_INDEX];
	}
	
	[_updateUserRequestManager release];
	[_s3Uploader release];
		
    [super dealloc];
}


@end

