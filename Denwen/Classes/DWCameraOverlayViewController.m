//
//  DWCameraOverlayViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCameraOverlayViewController.h"
#import "DWConstants.h"


static NSString* const kFlashOnImage				= @"flash_on.png";
static NSString* const kFlashOffImage				= @"flash_off.png";
static NSString* const kVideoOutLitImage            = @"video_out_lit.png";
static NSString* const kVideoOutImage               = @"video_out.png";
static NSString* const kSelectVideoImage            = @"select_video.png";
static NSString* const kSelectPhotoImage            = @"select_photo.png";



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
@synthesize letterBoxImage              = _letterBoxImage;

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
    self.letterBoxImage             = nil;
    
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
                setBackgroundImage:[UIImage imageNamed:kFlashOnImage] 
                          forState:UIControlStateNormal];
    }
    else {
        _cameraFlashMode = kCameraFlashModeOff;
        [self.flashButton 
                setBackgroundImage:[UIImage imageNamed:kFlashOffImage] 
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
                setBackgroundImage:[UIImage imageNamed:kVideoOutLitImage] 
                          forState:UIControlStateNormal];
        _isRecording = YES;
        self.cameraCaptureModeButton.enabled = NO;
        [_overlayDelegate startRecording];
    }
    else {
        [self.recordButton 
                setBackgroundImage:[UIImage imageNamed:kVideoOutImage] 
                          forState:UIControlStateNormal];
        _isRecording = NO;
        self.cameraCaptureModeButton.enabled = YES;
        [_overlayDelegate stopRecording];
    }
}

//----------------------------------------------------------------------------------------------------
- (IBAction)cameraCaptureModeButtonClicked:(id)sender {
    if (_cameraCaptureMode == kCameraCaptureModePhoto){
        _cameraCaptureMode              = kCameraCaptureModeVideo;
        self.recordButton.hidden        = NO;
        self.cameraButton.hidden        = YES;
        self.letterBoxImage.hidden      = YES;
        
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kSelectVideoImage] 
                          forState:UIControlStateNormal];
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kSelectVideoImage]
                          forState:UIControlStateHighlighted];
    }
    else { 
        _cameraCaptureMode              = kCameraCaptureModePhoto;
        self.recordButton.hidden        = YES;
        self.cameraButton.hidden        = NO;
        self.letterBoxImage.hidden      = NO;
        
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kSelectPhotoImage] 
                          forState:UIControlStateNormal];
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kSelectPhotoImage] 
                          forState:UIControlStateHighlighted];
    }
    
    [_overlayDelegate cameraCaptureModeChangedInOverlayView:_cameraCaptureMode];
}

@end
