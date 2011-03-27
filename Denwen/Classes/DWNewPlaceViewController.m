//
//  DWNewPlaceViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWNewPlaceViewController.h"

@interface DWNewPlaceViewController()
- (void)createNewPlace;
@end



@implementation DWNewPlaceViewController

@synthesize textFieldsContainerView, placeNameTextField, imagePickerButton, mapView,
				photoFilename=_photoFilename,placeLocation=_placeLocation;


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
		
		self.photoFilename = [NSString stringWithFormat:@""];
		
		_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
		_s3Uploader = [[DWS3Uploader alloc] initWithDelegate:self];
				
		_createInitiated = NO;
		_isUploading = NO;
	}
	return self;
}


// Additional UI configurations after the view has loaded
//
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.placeLocation = currentUserLocation;
		
	// rounded corners and border customization
	[[textFieldsContainerView layer] setCornerRadius:2.5f];
	[[textFieldsContainerView layer] setBorderWidth:1.0f];
	[[textFieldsContainerView layer] setMasksToBounds:YES];
	[[textFieldsContainerView layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
	
	[[imagePickerButton layer] setCornerRadius:2.5f];
	[[imagePickerButton layer] setBorderWidth:1.0f];
	[[imagePickerButton layer] setMasksToBounds:YES];
	[[imagePickerButton layer] setBorderColor:[[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]];
	
	//[textView becomeFirstResponder];	
	
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.placeLocation.coordinate, 500, 500);
	[mapView setRegion:region animated:YES];
	
	DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:self.placeLocation.coordinate addressDictionary:nil];
	//annotation.title = MAP_TOOLTIP_MSG;
	[mapView addAnnotation:annotation];
	[annotation release];
	
	[mapView selectAnnotation:annotation animated:NO];
			
	mbProgressIndicator = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:mbProgressIndicator];
	[mbProgressIndicator release];
}




#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification


// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
//
- (void)coordinateChanged_:(NSNotification *)notification {
	
	DDAnnotation *annotation = notification.object;
	
	CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
	self.placeLocation = tempLocation;
	[tempLocation release];
	//NSLog(@"3.0 version %@",[NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude]);
}



#pragma mark -
#pragma mark MKMapViewDelegate


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		
		CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
		self.placeLocation = tempLocation;
		[tempLocation release];
		
		//NSLog(@"4.0 version %@",[NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude]);
		//annotationView.canShowCallout = NO;
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
	
	MKAnnotationView *draggablePinView = [theMapView dequeueReusableAnnotationViewWithIdentifier:PIN_IDENTIFIER];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} 
	else {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:PIN_IDENTIFIER mapView:theMapView];
		
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}
	
	return draggablePinView;
}


// After an annotation is added, select it to allow dragging on first hold
//
- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views {
	
	for (id<MKAnnotation> currentAnnotation in mapView.annotations)    
		[mapView selectAnnotation:currentAnnotation animated:NO];
}



#pragma mark -
#pragma mark UI management


// Hide the keyboard when the map is tapped
//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event {
	[placeNameTextField resignFirstResponder];
	mapView.userInteractionEnabled = YES;
}


// Freezes the UI when the credentials are being evaluated on the server
//
- (void)freezeUI {	
	[placeNameTextField resignFirstResponder];
	
	mbProgressIndicator.labelText = @"Creating Place";
	[mbProgressIndicator showUsingAnimation:YES];
}


// Restores the UI back to its normal state
- (void)unfreezeUI {	
	[mbProgressIndicator hideUsingAnimation:YES];
}



#pragma mark -
#pragma mark Interface Builder Events


// User clicks the cancel button
//
- (void)cancelButtonClicked:(id)sender {
	[_delegate newPlaceCancelled];
}

// User clicks the create button
//
- (void)createButtonClicked:(id)sender {
	[self createNewPlace];
}


// User wants to select  profile picture
//
- (void)selectPhotoButtonClicked:(id)sender {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
													cancelButtonTitle:@"Cancel"	destructiveButtonTitle:nil
													otherButtonTitles:FIRST_TAKE_PHOTO_MSG,FIRST_CHOOSE_PHOTO_MSG,nil];
	[actionSheet showInView:self.view];	
	[actionSheet release];
}


// Handle clicks on the Photo modality selection action sheet
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	
	//Ignore event for the cancel button
	if(buttonIndex != 2) {
		[DWMemoryPool freeMemory];
		
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;
		imagePickerController.sourceType =  buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imagePickerController animated:YES];
		[imagePickerController release];
	}
}	


// Handles return key on the keyboard
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[placeNameTextField resignFirstResponder];	
	return YES;
}


// Limit the number of characters in the place name text field 
//
- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSUInteger newLength = [theTextField.text length] + [string length] - range.length;
    return (newLength > MAX_PLACE_NAME_LENGTH) ? NO : YES;
}


// Disable the interactions on the map as soon as the text field is clicked
// so that all the touches are now handled in the super view
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	mapView.userInteractionEnabled = NO;
	return YES;
}



#pragma mark -
#pragma mark Server interaction methods


// POST the place name, picture, coordinates et al to create a new place
//
- (void)createNewPlace {
	
	if (placeNameTextField.text.length == 0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Fields" 
														message:EMPTY_PLACENAME_MSG
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else {
		if(!_createInitiated)
			[self freezeUI];
		
		if(!_isUploading) {
			
			_createInitiated = NO;
			
			NSString *postString = [[NSString alloc] initWithFormat:@"place[name]=%@&place[lat]=%f&place[lon]=%f&email=%@&password=%@&place[photo_filename]=%@&ff=mobile",
									[placeNameTextField.text stringByEncodingHTMLCharacters],
									self.placeLocation.coordinate.latitude,
									self.placeLocation.coordinate.longitude,
									[DWSession sharedDWSession].currentUser.email,
									[DWSession sharedDWSession].currentUser.encryptedPassword,
									self.photoFilename
									];
			
			[_requestManager sendPostRequest:PLACES_URI withParams:postString];
			[postString release];
		}
		else
			_createInitiated = YES;
	}
}



#pragma mark -
#pragma mark UIImagePickerControllerDelegate


// Called when a user chooses a picture from the library of the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
	UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	UIImage *resizedImage = [DWImageHelper resizeImage:image 
										  scaledToSize:CGSizeMake(SIZE_PLACE_PRE_UPLOAD_IMAGE,SIZE_PLACE_PRE_UPLOAD_IMAGE)];
	
	[imagePickerButton setBackgroundImage:resizedImage forState:UIControlStateNormal];
	
	[self dismissModalViewControllerAnimated:YES];
	
	_isUploading = YES;
	[_s3Uploader uploadImage:image toFolder:S3_PLACES_FOLDER];
	
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
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
- (void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			 withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		DWPlace *place = [[DWPlace alloc] init];
		[place populate:[body objectForKey:PLACE_JSON_KEY]];
		[DWMemoryPool setObject:place atRow:PLACES_INDEX];
		place.pointerCount--;
		[place release];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_NEW_PLACE_CREATED object:place];
		[_delegate newPlaceCreated:place.hashedId];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:[[body objectForKey:PLACE_JSON_KEY] objectForKey:ERROR_MESSAGES_JSON_KEY]
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self unfreezeUI];
	}
	
}


// Fired when an error happens during the request
//
- (void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Problem connecting to the server, please try again"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[self unfreezeUI];
}





#pragma mark -
#pragma mark S3 Uploader Delegate methods


// Media has been successfully uploaded to S3
//
- (void)finishedUploadingMedia:(NSString*)filename {
	_isUploading = NO;
	
	self.photoFilename = filename;
	
	if(_createInitiated)
		[self createNewPlace];
}


// An error happened while uploading media to S3
//
- (void)errorUploadingMedia:(NSError*)error {
	_isUploading = NO;
	_createInitiated = NO;
	
	[self unfreezeUI];
	
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
	// Comment to preserve UIView elements upon a memory warning
    //[super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
	_delegate = nil;
	
	self.photoFilename = nil;
	self.placeLocation = nil;
	
	[_s3Uploader release];
	[_requestManager release];
	
	[textFieldsContainerView release];
	[placeNameTextField release];
	[imagePickerButton release];
	[mapView release];
	
	
    [super dealloc];
}



@end
