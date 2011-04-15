//
//  DWCameraOverlayViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCameraOverlayViewController.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@interface DWCameraOverlayViewController () 

- (void)showToggleCameraAndFlashButtons;

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCameraOverlayViewController

@synthesize cameraButton                = _cameraButton;
@synthesize cancelButton                = _cancelButton;
@synthesize flashButton                 = _flashButton;
@synthesize toggleCameraButton          = _toggleCameraButton;
@synthesize photoLibraryButton          = _photoLibraryButton;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate {
    self = [super init];
    if (self) {
        _overlayDelegate            = theDelegate;
        _cameraFlashMode            = kCameraFlashModeOff;     
    }
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.cameraButton           = nil;
    self.cancelButton           = nil;
    self.flashButton            = nil;
    self.toggleCameraButton     = nil;
    self.photoLibraryButton     = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private Methods

//----------------------------------------------------------------------------------------------------
- (void)showToggleCameraAndFlashButtons {
    self.toggleCameraButton.hidden      = NO;
    self.flashButton.hidden             = NO;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark - View lifecycle

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    self.view.backgroundColor   = [UIColor clearColor];
    
    //if ([[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasFlash])
    //    [self showToggleCameraAndFlashButtons];
    
    [super viewDidLoad];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cameraButtonClicked:(id)sender {
	[_overlayDelegate cameraButtonClickedInOverlayView];
}

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
	[_overlayDelegate cancelButtonClickedInOverlayView];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)flashButtonClicked:(id)sender {
    if (_cameraFlashMode == kCameraFlashModeOff) {
        _cameraFlashMode = kCameraFlashModeOn;
        [self.flashButton setTitle:@"Flash On" forState:UIControlStateNormal];
    }
    else {
        _cameraFlashMode = kCameraFlashModeOff;
        [self.flashButton setTitle:@"Flash Off" forState:UIControlStateNormal];
    }
    [_overlayDelegate flashButtonClickedInOverlayView:_cameraFlashMode];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)toggleCameraButtonClicked:(id)sender {
    [_overlayDelegate toggleCameraButtonClickedInOverlayView];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)photoLibraryButtonClicked:(id)sender {
    [_overlayDelegate photoLibraryButtonClickedInOverlayView];
}

@end
