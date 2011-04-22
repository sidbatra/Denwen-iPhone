//
//  DWCameraOverlayViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCameraOverlayViewController.h"
#import "DWConstants.h"


static NSString* const kImgFlashOn				= @"flash_on.png";
static NSString* const kImgFlashOff				= @"flash_off.png";
static NSString* const kImgVideoOutLit          = @"video_out_lit.png";
static NSString* const kImgVideoOut             = @"video_out.png";
static NSString* const kImgSelectVideo          = @"select_video.png";
static NSString* const kImgSelectPhoto          = @"select_photo.png";



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
@synthesize timerButton                 = _timerButton;
@synthesize timer                       = _timer;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate {
    self = [super init];
    if (self) {
        _overlayDelegate            = theDelegate;
        _cameraFlashMode            = kCameraFlashModeOff;  
        _cameraCaptureMode          = kCameraCaptureModePhoto;
        _cameraDevice               = kCameraDeviceRear;
        _isRecording                = NO;
        _recordingTime              = 0;
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
    self.timerButton                = nil;
    self.timer                      = nil;
    
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

    #if !(TARGET_IPHONE_SIMULATOR)
		if ([[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasFlash])
			[self showToggleCameraAndFlashButtons];
	#endif
    
    [super viewDidLoad];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Customize views
//----------------------------------------------------------------------------------------------------
- (void)hideCameraCaptureModeButtonForPickingImages {
    self.cameraCaptureModeButton.hidden = YES;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Timer Methods
//----------------------------------------------------------------------------------------------------
- (void)updateTimerDisplay {
    _recordingTime++;
    NSString *time = _recordingTime < 10 ? 
                        [NSString stringWithFormat:@"00:00:0%d",_recordingTime]:
                        [NSString stringWithFormat:@"00:00:%d",_recordingTime]; 
    
    [self.timerButton setTitle:time 
                      forState:UIControlStateNormal];
    
    if (_recordingTime == kMaxVideoDuration) {
        [self.timer invalidate];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)displayRecordingTimer {
    self.timerButton.hidden = NO;
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1 
                                                   target:self 
                                                 selector:@selector(updateTimerDisplay) 
                                                 userInfo:nil 
                                                  repeats:YES]; 
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
                setBackgroundImage:[UIImage imageNamed:kImgFlashOn] 
                          forState:UIControlStateNormal];
    }
    else {
        _cameraFlashMode = kCameraFlashModeOff;
        [self.flashButton 
                setBackgroundImage:[UIImage imageNamed:kImgFlashOff] 
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
                setBackgroundImage:[UIImage imageNamed:kImgVideoOutLit] 
                          forState:UIControlStateNormal];
        _isRecording = YES;
        self.cameraCaptureModeButton.enabled    = NO;
        self.toggleCameraButton.hidden          = YES;
        self.photoLibraryButton.hidden          = YES;
        [_overlayDelegate startRecording];
    }
    else {
        [self.recordButton 
                setBackgroundImage:[UIImage imageNamed:kImgVideoOut] 
                          forState:UIControlStateNormal];
        _isRecording = NO;
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
                setBackgroundImage:[UIImage imageNamed:kImgSelectVideo] 
                          forState:UIControlStateNormal];
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kImgSelectVideo]
                          forState:UIControlStateHighlighted];
    }
    else { 
        _cameraCaptureMode              = kCameraCaptureModePhoto;
        self.recordButton.hidden        = YES;
        self.cameraButton.hidden        = NO;
        self.letterBoxImage.hidden      = NO;
        
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kImgSelectPhoto] 
                          forState:UIControlStateNormal];
        [self.cameraCaptureModeButton 
                setBackgroundImage:[UIImage imageNamed:kImgSelectPhoto] 
                          forState:UIControlStateHighlighted];
    }
    
    [_overlayDelegate cameraCaptureModeChangedInOverlayView:_cameraCaptureMode];
}

@end
