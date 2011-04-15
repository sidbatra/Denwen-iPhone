//
//  DWCameraOverlayViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol DWCameraOverlayViewControllerDelegate;

/**
 * Camera Overlay View Controller
 */
@interface DWCameraOverlayViewController : UIViewController {
    id <DWCameraOverlayViewControllerDelegate>      _overlayDelegate;
    
    UIButton        *_cameraButton;
    UIButton        *_cancelButton;
    UIButton        *_flashButton;
    UIButton        *_toggleCameraButton;
    UIButton        *_photoLibraryButton;
}


/**
 * Init with delegate to capture camera action events
 */
- (id)initWithDelegate:(id)theDelegate;


/**
 * IBOutlet properties
 */
@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *flashButton;
@property (nonatomic, retain) IBOutlet UIButton *toggleCameraButton;
@property (nonatomic, retain) IBOutlet UIButton *photoLibraryButton;


/**
 * IBActions
 */
- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)flashButtonClicked:(id)sender;
- (IBAction)toggleCameraButtonClicked:(id)sender;
- (IBAction)photoLibraryButtonClicked:(id)sender;

@end



/**
 * Delegate protocol to receive updates events
 * from camera overlay view controller
 */
@protocol DWCameraOverlayViewControllerDelegate

- (void)cameraButtonClickedInOverlayView;
- (void)cancelButtonClickedInOverlayView;
- (void)toggleCameraButtonClickedInOverlayView;
- (void)photoLibraryButtonClickedInOverlayView;

@end