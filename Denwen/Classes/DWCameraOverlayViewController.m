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
@synthesize recordButton                = _recordButton;
@synthesize cameraCaptureModeButton     = _cameraCaptureModeButton;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate {
    self = [super init];
    if (self) {
        _overlayDelegate            = theDelegate;
        _cameraFlashMode            = kCameraFlashModeOff;  
        _cameraCaptureMode          = kCameraCaptureModePhoto;
        _cameraDevice               = kCameraDeviceRear;
        _isRecording                = NO;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.cameraButton               = nil;
    self.cancelButton               = nil;
    self.flashButton                = nil;
    self.toggleCameraButton         = nil;
    self.photoLibraryButton         = nil;
    self.recordButton               = nil;
    self.cameraCaptureModeButton    = nil;
    
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

    //#ifndef TARGET_IPHONE_SIMULATOR
    if ([[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasFlash])
        [self showToggleCameraAndFlashButtons];
	//#endif
    
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
        [self.flashButton 
                setBackgroundImage:[UIImage imageNamed:@"flash_on.png"] 
                          forState:UIControlStateNormal];
    }
    else {
        _cameraFlashMode = kCameraFlashModeOff;
        [self.flashButton 
                setBackgroundImage:[UIImage imageNamed:@"flash_off.png"] 
                          forState:UIControlStateNormal];
    }
    [_overlayDelegate flashModeChangedInOverlayView:_cameraFlashMode];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)toggleCameraButtonClicked:(id)sender {
    if (_cameraDevice == kCameraDeviceRear)
        _cameraDevice = kCameraDeviceFront;
    else
        _cameraDevice = kCameraDeviceRear;
    
    [_overlayDelegate cameraDeviceChangedInOverlayView:_cameraDevice];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)photoLibraryButtonClicked:(id)sender {
    [_overlayDelegate photoLibraryButtonClickedInOverlayView];
}

//----------------------------------------------------------------------------------------------------
- (IBAction)recordButtonClicked:(id)sender {
    if (!_isRecording) {
        [self.recordButton 
                setBackgroundImage:[UIImage imageNamed:@"video_out_lit.png"] 
                          forState:UIControlStateNormal];
        _isRecording = YES;
        [_overlayDelegate startRecording];
    }
    else {
        [self.recordButton 
                setBackgroundImage:[UIImage imageNamed:@"video_out.png"] 
                          forState:UIControlStateNormal];
        _isRecording = NO;
        [_overlayDelegate stopRecording];
    }
}

//----------------------------------------------------------------------------------------------------
- (IBAction)cameraCaptureModeButtonClicked:(id)sender {
    if (_cameraCaptureMode == kCameraCaptureModePhoto){
        _cameraCaptureMode          = kCameraCaptureModeVideo;
        self.recordButton.hidden    = NO;
        self.cameraButton.hidden    = YES;
        
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:@"select_video.png"] 
                          forState:UIControlStateNormal];
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:@"select_video.png"] 
                          forState:UIControlStateHighlighted];
    }
    else { 
        _cameraCaptureMode          = kCameraCaptureModePhoto;
        self.recordButton.hidden    = YES;
        self.cameraButton.hidden    = NO;
        
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:@"select_photo.png"] 
                          forState:UIControlStateNormal];
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:@"select_photo.png"] 
                          forState:UIControlStateHighlighted];
    }
    
    [_overlayDelegate cameraCaptureModeChangedInOverlayView:_cameraCaptureMode];
}

@end
