//
//  DWPlaceViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlaceViewController.h"


//Declarations for private methods
//
@interface DWPlaceViewController () 
- (void)showCreateNewItem;

- (void)showCreateButton;
- (void)hideCreateButton;

- (void)displayProfilePicture;
- (void)updateTitle;

- (void)createFollowing:(NSDictionary*)followJSON;

- (void)sendFollowRequest;
- (void)sendUnfollowRequest;
- (void)sendUpdatePlaceRequest:(NSString*)placePhotoFilename;
@end



@implementation DWPlaceViewController


@synthesize placeJSON=_placeJSON,following=_following;



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
-(id)initWithPlace:(DWPlace*)place withNewItemPrompt:(BOOL)newItemPrompt andDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		_newItemPrompt = newItemPrompt;
		_isViewLoaded = NO;
		_isReadyForCreateItem = NO;
		_placeJSON = nil;
		_origPlace = place;		
			
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(largePlaceImageLoaded:) 
													 name:kNImgLargePlaceLoaded
												   object:nil];
		
	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemCreated:) 
													 name:N_NEW_ITEM_CREATED 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeLoaded:) 
													 name:kNPlaceLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeError:) 
													 name:kNPlaceError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeUpdated:) 
													 name:kNPlaceUpdated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeUpdateError:) 
													 name:kNPlaceUpdateError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingModified:) 
													 name:kNNewFollowingCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingError:)
													 name:kNNewFollowingError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingModified:) 
													 name:kNFollowingDestroyed
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingError:)
													 name:kNFollowingDestroyError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageUploadDone:) 
													 name:kNS3UploadDone
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageUploadError:) 
													 name:kNS3UploadError
												   object:nil];		
		
		
	}
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	

	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
																	style:UIBarButtonItemStyleBordered
																   target:nil
																   action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	

	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];
	
	if(!_isLoadedOnce)
		[self loadItems];
}


// Ensure create new item view is shown only when
// view is fully visible
//
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_isViewLoaded = YES;
	
	if(_newItemPrompt && _isReadyForCreateItem)
		[self showCreateNewItem];
}


// Display the create button
//
- (void)showCreateButton {
	
	if([[DWSession sharedDWSession] isActive]) {
		UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																						target:self 
																						action:@selector(didPressCreateNewItem:event:) ];
		self.navigationItem.rightBarButtonItem = composeButton;
		[composeButton release];
	}
}


// Hide the create button
//
- (void)hideCreateButton {
	self.navigationItem.rightBarButtonItem = nil;
}


// Display the create a new item controller for the current place
//
- (void)showCreateNewItem {
	DWNewItemViewController *newItemView = [[DWNewItemViewController alloc] initWithDelegate:self 
																			   withPlaceName:_place.name
																				 withPlaceID:_place.databaseID
																			   withForcePost:_newItemPrompt];
	[self.navigationController presentModalViewController:newItemView animated:!_newItemPrompt];
	[newItemView release];
}


// User presses the compose icon
//
- (void)didPressCreateNewItem:(id)sender event:(id)event {
	[self showCreateNewItem];
}


// Display the place profile picture
//
- (void)displayProfilePicture {
	if(_place.hasPhoto) {
		DWImageViewController *imageView = [[DWImageViewController alloc] initWithImageURL:_place.largeURL];
		imageView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:imageView animated:YES];
		[imageView release];			
	}
}


// Update the title using the followers of the place
//
- (void)updateTitle {
	self.title = [_place titleText];
}

// Init and populate the following memeber variable
//
- (void)createFollowing:(NSDictionary*)followJSON {
	DWFollowing *tempFollowing = [[DWFollowing alloc] init];
	self.following = tempFollowing;
	[tempFollowing release];
	
	[self.following populate:followJSON];
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
	_newItemPrompt = NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}




#pragma mark -
#pragma mark ItemManager 


// Fetches recent items from places being followed by the current user
//
- (BOOL)loadItems {
	[super loadItems];
	
	[[DWRequestsManager sharedDWRequestsManager] getPlaceWithHashedID:_origPlace.hashedId
													   withDatabaseID:_place.databaseID
															   atPage:_currentPage];
	return YES;
}


// Sends a follow request to the server
//
- (void)sendFollowRequest {
	mbProgressIndicator.labelText = @"Following";
	[mbProgressIndicator showUsingAnimation:YES];
	
	[[DWRequestsManager sharedDWRequestsManager] createFollowing:_place.databaseID];
}



// Sends an unfollow request to the server
//
- (void)sendUnfollowRequest {
	mbProgressIndicator.labelText = @"Unfollowing";
	[mbProgressIndicator showUsingAnimation:YES];
	
	[[DWRequestsManager sharedDWRequestsManager] destroyFollowing:self.following.databaseID
													ofPlaceWithID:_place.databaseID];
}


// Sends a PUT request to update the picture of the place
//
- (void)sendUpdatePlaceRequest:(NSString*)placePhotoFilename {
	
	[[DWRequestsManager sharedDWRequestsManager] updatePhotoForPlaceWithID:_place.databaseID 
														   toPhotoFilename:placePhotoFilename];
}



#pragma mark -
#pragma mark RequestManager Delegate methods

- (void)placeLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary *body = [info objectForKey:kKeyBody];
		
		NSArray *items = [body objectForKey:ITEMS_JSON_KEY];
		[_itemManager populateItems:items withBuffer:(_currentPage==kPagInitialPage) withClear:_isReloading];
		
		
		if(_place)
			[DWMemoryPool removeObject:_place atRow:PLACES_INDEX];
		
		/* Create or fetch the place from the memory pool*/
		NSDictionary *placeJSON = [body objectForKey:PLACE_JSON_KEY];
		self.placeJSON = placeJSON;
		_place = (DWPlace*)[DWMemoryPool getOrSetObject:placeJSON atRow:PLACES_INDEX];
		
		
		NSDictionary *followJSON = [body objectForKey:FOLLOWING_JSON_KEY];
		self.following = nil;
		
		if(![followJSON isKindOfClass:[NSNull class]] && [followJSON count])
			[self createFollowing:followJSON];
		
		[self updateTitle];
		
		
		_tableViewUsage = kTableViewAsData;			
		
		if(!_isLoadedOnce) {
			[self showCreateButton];
			_isLoadedOnce = YES;
		}
		
		
		if(_newItemPrompt && _isViewLoaded)
			[self showCreateNewItem];
		else
			_isReadyForCreateItem = YES;
	}
	
	[self finishedLoadingItems];
	[self.tableView reloadData];
}

- (void)placeError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID)
		return;
	
	if(!_isReloading)
		[mbProgressIndicator hideUsingAnimation:YES];
	
	[self finishedLoadingItems];
}

- (void)placeUpdated:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID)
		return;	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary *body = [info objectForKey:kKeyBody];
		NSDictionary *placeJSON = [body objectForKey:PLACE_JSON_KEY];
		[_place updatePreviewURLs:placeJSON];
		self.placeJSON = placeJSON;		
	}
	
	[mbProgressIndicator hideUsingAnimation:YES];
}

- (void)placeUpdateError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID)
		return;
	
	[mbProgressIndicator hideUsingAnimation:YES];
}


- (void)followingModified:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID)
		return;
	
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSDictionary *body = [info objectForKey:kKeyBody];
		
		// Pull the placeCell for refreshing it
		//
		NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		DWPlaceCell *placeCell = (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
		
		if(self.following) { // If already following place, unfollow it
			self.following = nil;
			[placeCell displayUnfollowingState];
			[_place updateFollowerCount:-1];
			[[NSNotificationCenter defaultCenter] postNotificationName:N_PLACE_UNFOLLOWED object:self.placeJSON];
		}
		else { 
			[self createFollowing:body];
			[placeCell displayFollowingState];
			[_place updateFollowerCount:1];
			[[NSNotificationCenter defaultCenter] postNotificationName:N_PLACE_FOLLOWED object:self.placeJSON];
		}
		
		[self updateTitle];
		
		//Mark changes to global variables, indicating a refresh is needed on followed content
		[DWSession sharedDWSession].refreshFollowedItems = YES;
		
	}
	
	[mbProgressIndicator hideUsingAnimation:YES];
}

- (void)followingError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID)
		return;
	
	if(!_isReloading)
		[mbProgressIndicator hideUsingAnimation:YES];
}

- (void)imageUploadDone:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		//Use the updated photo filename to update the database entry for the place
		//
		[self sendUpdatePlaceRequest:[info objectForKey:kKeyFilename]];
	}
}

- (void)imageUploadError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger resourceID = [[info objectForKey:kKeyResourceID] integerValue];
	
	if(_uploadID == resourceID) {
		[mbProgressIndicator hideUsingAnimation:NO];
		
		
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
#pragma mark Notification handlers

- (void)largePlaceImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData)
		return;
	
	NSDictionary *info	= [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != _place.databaseID) {
		return;
	}
	
	UIImage *image = [info objectForKey:kKeyImage];
	
	NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	DWPlaceCell *cell = (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
	cell.placeBackgroundImage.image = image;
	[self.refreshHeaderView applyBackgroundImage:image 
								   withFadeImage:[UIImage imageNamed:PLACE_VIEW_FADE_IMAGE_NAME]
							 withBackgroundColor:[UIColor blackColor]
	 ];
	
}



// New item created
//
- (void)newItemCreated:(NSNotification*)notification {
	DWItem *item = (DWItem*)[notification object];
	
	if(_isLoadedOnce && item.place == _place)
		[self addNewItem:item atIndex:1];
}


// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
	[self showCreateButton];
	[self hardRefresh];
}


#pragma mark -
#pragma mark Table view methods

// Calculates the height of cells based on the data within them
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 0;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row==0)
		height = FOLLOW_PLACE_CELL_HEIGHT;
	else
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];

	return height;
}


// Override the cellForRowAtIndexPath method to insert place information in the first cell 
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row == 0) {
		DWPlaceCell *cell = (DWPlaceCell*)[tableView dequeueReusableCellWithIdentifier:FOLLOW_PLACE_CELL_IDENTIFIER];
		
		if (!cell) {
			cell = [[[DWPlaceCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:FOLLOW_PLACE_CELL_IDENTIFIER
											   withRow:indexPath.row 
											  andTaget:self] 
					autorelease];
		}
		
		if(self.following)
			[cell displayFollowingState];
		else
			[cell displayUnfollowingState];
		
		
		if([[DWSession sharedDWSession] isActive]) 
			[cell displaySignedInState:_place.hasPhoto];
		else
			[cell displaySignedOutState];
		

		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[cell placeName].text = _place.name;
		
		[_place startLargePreviewDownload];
		
		if(_place.largePreviewImage)
			cell.placeBackgroundImage.image = _place.largePreviewImage;
		else
			cell.placeBackgroundImage.image = [UIImage imageNamed:kImgGenericPlaceHolder];
		
		return cell;
	}
	else {
		cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
		
		if(_tableViewUsage == kTableViewAsData && indexPath.row < [_itemManager totalItems])
			[(DWItemFeedCell*)cell disablePlaceButtons];
	}
	
	
	return cell;
}



#pragma mark -
#pragma mark Cell Click events


// Handles click event on the table view cell
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(_tableViewUsage == kTableViewAsData && indexPath.row == 0) {
		DWPlaceDetailsViewController *placeDetailsViewController = [[DWPlaceDetailsViewController alloc] 
																	initWithPlace:_place];
		placeDetailsViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:placeDetailsViewController animated:YES];
		[placeDetailsViewController release];
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}

}


// Override clicks on Place Name to prevent recursive navigation
//
- (void)didTapPlaceName:(id)sender event:(id)event {
	//[self displayProfilePicture];
}


// Override clicks on Place Image to prevent recursive navifation
//
- (void)didTapPlaceImage:(id)sender event:(id)event {
	//[self displayProfilePicture];
}


// User clicks the follow place button
//
- (void)didTapFollowButton:(id)sender event:(id)event {
	if([[DWSession sharedDWSession] isActive])
	   [self sendFollowRequest];
	else {
		UIAlertView *alert;
		alert = [[UIAlertView alloc] initWithTitle:@"Denwen" 
										   message:FOLLOW_LOGGEDOUT_MSG 
										  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


// User clicks the Unfollow place button
//
- (void)didTapUnfollowButton:(id)sender event:(id)event {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
										 cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow"
										 otherButtonTitles:nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}


// User clicks the share place button
//
- (void)didTapShareButton:(id)sender event:(id)event {
	if([[DWSession sharedDWSession] isActive]) {
		DWShareViewController *shareView = [[DWShareViewController alloc] initWithDelegate:self andPlace:_place];
		shareView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self.navigationController presentModalViewController:shareView animated:YES];
		[shareView release];
	}
	else {
		UIAlertView *alert;
		alert = [[UIAlertView alloc] initWithTitle:@"Denwen" 
										   message:SHARE_LOGGEDOUT_MSG 
										  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

}



// User clicks the place image to change photo
//
- (void)didTapPlaceMediumImage:(id)sender event:(id)event {
	
	if([[DWSession sharedDWSession] isActive]) {
		UIActionSheet *actionSheet = nil;
		
		if(_place.hasPhoto) {
			actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
													cancelButtonTitle:CANCEL_PHOTO_MSG	destructiveButtonTitle:nil
													otherButtonTitles:BETTER_TAKE_PHOTO_MSG,BETTER_CHOOSE_PHOTO_MSG,nil];
		}
		else {
			actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
													cancelButtonTitle:CANCEL_PHOTO_MSG	destructiveButtonTitle:nil
													otherButtonTitles:FIRST_TAKE_PHOTO_MSG,FIRST_CHOOSE_PHOTO_MSG,nil];

		}
		
		actionSheet.tag = 0;
		[actionSheet showInView:self.tabBarController.view];
		[actionSheet release];
	}
	
}


// Handle clicks on the Photo modality selection action sheet
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	

	//Tag 0 is for change picture while tag 1 is for unfollow
	if(actionSheet.tag == 0 && buttonIndex != 2) {
		[DWMemoryPool freeMemory];
		
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;		
		imagePickerController.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
	}
	if (actionSheet.tag == 1 && buttonIndex == 0) {
		[self sendUnfollowRequest];
	}
}	



#pragma mark -
#pragma mark ShareViewControllerDelegate

// User cancels the shareViewController
-(void)shareViewCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)shareViewFinished:(NSString*)data sentTo:(NSInteger)sentTo {
	[self.navigationController dismissModalViewControllerAnimated:YES];

	[[DWRequestsManager sharedDWRequestsManager] createShareForPlaceWithID:_place.databaseID 
																  withData:data 
																	sentTo:sentTo];
}



#pragma mark -
#pragma mark UIImagePickerControllerDelegate


// Called when a user chooses a picture from the library of the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
	UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	[self dismissModalViewControllerAnimated:YES];
	
	mbProgressIndicator.labelText = @"Loading";
	[mbProgressIndicator showUsingAnimation:YES];
	
	
	_uploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:image 
																		toFolder:S3_PLACES_FOLDER];
	
	[_place updatePreviewImages:image];
	
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
		UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


// Called when user cancels the photo selection / creation process
//
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}


// Called when the image is saved to the disk
//
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	/* TODO
	 UIAlertView *alert;
	 
	 // Unable to save the image  
	 if (error) {
	 alert = [[UIAlertView alloc] initWithTitle:@"Error" 
	 message:@"Unable to save image to Photo Album." 
	 delegate:self cancelButtonTitle:@"Ok" 
	 otherButtonTitles:nil];
	 else 
	 
	 [alert show];
	 [alert release]; 
	 */
}





#pragma mark -
#pragma mark Memory management

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
	
	if(_place) {
		_place.largePreviewImage = nil;
		[DWMemoryPool removeObject:_place atRow:PLACES_INDEX];
	}
	
	self.placeJSON = nil;
	self.following = nil;
			
    [super dealloc];
}


@end

