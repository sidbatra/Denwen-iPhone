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


@synthesize placeHashedID=_placeHashedID,placeJSON=_placeJSON,following=_following;



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithPlaceID:(NSString*)placeHashedID withNewItemPrompt:(BOOL)newItemPrompt andDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		self.placeHashedID = placeHashedID;
		_newItemPrompt = newItemPrompt;
		_isViewLoaded = NO;
		_isReadyForCreateItem = NO;
		_placeJSON = nil;
		
		_followRequestManager = [[DWRequestManager alloc] initWithDelegate:self andInstanceID:1];
		_updatePlaceRequestManager = [[DWRequestManager alloc] initWithDelegate:self andInstanceID:2];
		_s3Uploader = [[DWS3Uploader alloc] initWithDelegate:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumPlacePreviewDone:) 
													 name:N_MEDIUM_PLACE_PREVIEW_DONE
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(largePlacePreviewDone:) 
													 name:N_LARGE_PLACE_PREVIEW_DONE
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemCreated:) 
													 name:N_NEW_ITEM_CREATED 
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
	
	if([DWSessionManager isSessionActive]) {
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
	
	
	NSString *urlString = nil;
	
	if([DWSessionManager isSessionActive])
		urlString = [[NSString alloc] initWithFormat:@"%@%@.json?email=%@&password=%@&page=%d&ff=mobile",
					 PLACE_HASHED_SHOW_URI,
					 self.placeHashedID,
					 currentUser.email,
					 currentUser.encryptedPassword,
					 _currentPage
					 ];
	else
		urlString = [[NSString alloc] initWithFormat:@"%@%@.json?page=%d&ff=mobile",
					 PLACE_HASHED_SHOW_URI,
					 self.placeHashedID,
					 _currentPage
					 ];
	
	[_requestManager sendGetRequest:urlString];
	[urlString release];
	
	return YES;
}


// Sends a follow request to the server
//
- (void)sendFollowRequest {
	mbProgressIndicator.labelText = @"Following";
	[mbProgressIndicator showUsingAnimation:YES];
	
	NSString *paramString = [[NSString alloc] initWithFormat:@"place_id=%d&email=%@&password=%@&ff=mobile",
							_place.databaseID,
							 currentUser.email,
							 currentUser.encryptedPassword
							 ];
	
	[_followRequestManager sendPostRequest:FOLLOWINGS_URI withParams:paramString];
	[paramString release];
}



// Sends an unfollow request to the server
//
- (void)sendUnfollowRequest {
	mbProgressIndicator.labelText = @"Unfollowing";
	[mbProgressIndicator showUsingAnimation:YES];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@%d.json?email=%@&password=%@&ff=mobile",
							FOLLOWINGS_DELETE_URI,
							self.following.databaseID,
							currentUser.email,
							currentUser.encryptedPassword
							];
	
	[_followRequestManager sendDeleteRequest:urlString withParams:@""];
	[urlString release];
}


// Sends a PUT request to update the picture of the place
//
- (void)sendUpdatePlaceRequest:(NSString*)placePhotoFilename {
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@%d.json?photo_filename=%@&email=%@&password=%@&ff=mobile",
							PLACE_SHOW_URI,
							_place.databaseID,
							placePhotoFilename,
							currentUser.email,
							currentUser.encryptedPassword
							];
	
	[_updatePlaceRequestManager sendPutRequest:urlString withParams:@""];
	[urlString release];
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
- (void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if(instanceID == 0) { //Place show response
		
		if([status isEqualToString:SUCCESS_STATUS]) {
			
			NSArray *items = [body objectForKey:ITEMS_JSON_KEY];
			[_itemManager populateItems:items withBuffer:(_currentPage==INITIAL_PAGE_FOR_REQUESTS) withClear:_reloading];
			
			
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
			
			
			_tableViewUsage = TABLE_VIEW_AS_DATA;			
			
			if(!_isLoadedOnce) {
				[self showCreateButton];
				_isLoadedOnce = YES;
			}
			
					
			if(_newItemPrompt && _isViewLoaded)
				[self showCreateNewItem];
			else
				_isReadyForCreateItem = YES;
		}
		else {
			
		}
		
		[self finishedLoadingItems];
		[self.tableView reloadData];
	}
	else if(instanceID == 1) { //Follow,Unfollow responses
		
		if([status isEqualToString:SUCCESS_STATUS]) {
						
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
			currentUserFollowedItemsRefresh = YES;
			currentUserFollowedPlacesRefresh = YES;

		}
		else{
		}
		
		[mbProgressIndicator hideUsingAnimation:YES];
	}
	else if(instanceID == 2) { // Update place response
		
		if([status isEqualToString:SUCCESS_STATUS]) {
			NSDictionary *placeJSON = [body objectForKey:PLACE_JSON_KEY];
			[_place updatePreviewURLs:placeJSON];
			self.placeJSON = placeJSON;
		}
		else {
				
		}
		
		[mbProgressIndicator hideUsingAnimation:YES];
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
- (void)mediumPlacePreviewDone:(NSNotification*)notification {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA)
		return;
	
	DWPlace *placeWithImage =  (DWPlace*)[notification object];
	
	if(_place == placeWithImage) {
		NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		
		DWPlaceCell *cell = (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
		[cell setMediumPreviewPlaceImage:placeWithImage.mediumPreviewImage];
	}	
}


// Fired when a place has downloaded a large preview image
//
- (void)largePlacePreviewDone:(NSNotification*)notification {
	
	if(_tableViewUsage != TABLE_VIEW_AS_DATA)
		return;
	
	DWPlace *placeWithImage =  (DWPlace*)[notification object];
	
	if(_place == placeWithImage) {
		NSIndexPath *placeIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		
		DWPlaceCell *cell = (DWPlaceCell*)[self.tableView cellForRowAtIndexPath:placeIndexPath];
		cell.placeBackgroundImage.image = placeWithImage.largePreviewImage;
		[self.refreshHeaderView applyBackgroundImage:placeWithImage.largePreviewImage 
								withFadeImage:[UIImage imageNamed:PLACE_VIEW_FADE_IMAGE_NAME]
								 withBackgroundColor:[UIColor blackColor]
		 ];
	}	
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
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row==0)
		height = FOLLOW_PLACE_CELL_HEIGHT;
	else
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];

	return height;
}


// Override the cellForRowAtIndexPath method to insert place information in the first cell 
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == 0) {
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
		
		
		if([DWSessionManager isSessionActive]) 
			[cell displaySignedInState:_place.hasPhoto];
		else
			[cell displaySignedOutState];
		

		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[cell placeName].text = _place.name;
		
		[_place startMediumPreviewDownload];
		[_place startLargePreviewDownload];
		
		//Test if the place preview got pulled from the cache instantly
		if (_place.mediumPreviewImage)
			[cell setMediumPreviewPlaceImage:_place.mediumPreviewImage];
		else
			[cell setMediumPreviewPlaceImage:[UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME]];
		
		if(_place.largePreviewImage)
			cell.placeBackgroundImage.image = _place.largePreviewImage;
		else
			cell.placeBackgroundImage.image = [UIImage imageNamed:GENERIC_PLACEHOLDER_IMAGE_NAME];
		
		return cell;
	}
	else {
		cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
		
		if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row < [_itemManager totalItems])
			[(DWItemFeedCell*)cell disablePlaceButtons];
	}
	
	
	return cell;
}



#pragma mark -
#pragma mark Cell Click events


// Handles click event on the table view cell
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && indexPath.row == 0) {
		DWPlaceDetailsViewController *placeDetailsViewController = [[DWPlaceDetailsViewController alloc] 
																	initWithPlaceName:_place.name placeAddress:[_place displayAddress] 
																	andLocation:_place.location];
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
	if([DWSessionManager isSessionActive])
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
	if([DWSessionManager isSessionActive]) {
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
	
	if([DWSessionManager isSessionActive]) {
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

	//if(buttonIndex == 0) {
	//	if(_place.hasPhoto) 
	//		[self displayProfilePicture];
	//}
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
	[currentUser createShare:data sentTo:sentTo forPlace:_place.databaseID];
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
	
	[_s3Uploader uploadImage:image toFolder:S3_PLACES_FOLDER];
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
#pragma mark S3 Uploader Delegate methods


// Media has been successfully uploaded to S3
//
- (void)finishedUploadingMedia:(NSString*)filename {
	//Use the updated photo filename to update the database entry for the place
	//
	[self sendUpdatePlaceRequest:filename];
}


// An error happened while uploading media to S3
//
- (void)errorUploadingMedia:(NSError*)error {
	
	[mbProgressIndicator hideUsingAnimation:NO];

	
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

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
	
	if(_place) {
		_place.mediumPreviewImage = nil;
		_place.largePreviewImage = nil;
		[DWMemoryPool removeObject:_place atRow:PLACES_INDEX];
	}
	
	self.placeHashedID = nil;
	self.placeJSON = nil;
	self.following = nil;
	
	[_followRequestManager release];
	[_updatePlaceRequestManager release];
	[_s3Uploader release];
		
    [super dealloc];
}


@end

