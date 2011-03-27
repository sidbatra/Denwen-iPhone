//
//  DWNewPlaceViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DDAnnotationView.h"
#import "DDAnnotation.h"

#import "DWPlace.h"
#import "DWRequestManager.h"
#import "DWS3Uploader.h"
#import "MBProgressHUD.h"
#import "DWSession.h"
#import "NSString+Helpers.h"
#import "DWMemoryPool.h"
#import "DWImageHelper.h"


@protocol DWNewPlaceViewControllerDelegate;

@interface DWNewPlaceViewController : UIViewController<UITextFieldDelegate,DWRequestManagerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,DWS3UploaderDelegate,MKMapViewDelegate> {
	
	UIView *textFieldsContainerView;
	UITextField *placeNameTextField;
	UIButton *imagePickerButton;
	MKMapView *mapView;
	
	MBProgressHUD *mbProgressIndicator;
	
	NSString *_photoFilename;			
	CLLocation *_placeLocation;
	
	BOOL _isUploading;
	BOOL _createInitiated;
	
	DWS3Uploader *_s3Uploader;
	DWRequestManager *_requestManager;
	
	id <DWNewPlaceViewControllerDelegate> _delegate;
}


@property (nonatomic, retain) IBOutlet UIView *textFieldsContainerView;
@property (nonatomic, retain) IBOutlet UITextField *placeNameTextField;
@property (nonatomic, retain) IBOutlet UIButton *imagePickerButton;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (copy) NSString *photoFilename;
@property (copy) CLLocation *placeLocation;



- (id)initWithDelegate:(id)delegate;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)createButtonClicked:(id)sender;
- (IBAction)selectPhotoButtonClicked:(id)sender;

@end

@protocol DWNewPlaceViewControllerDelegate
- (void)newPlaceCancelled;
- (void)newPlaceCreated:(NSString*)placeHashedID;
@end
