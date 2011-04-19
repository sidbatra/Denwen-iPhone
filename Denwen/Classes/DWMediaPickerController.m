//
//  DWMediaPickerController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWMediaPickerController.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"
#import "DWRequestsManager.h"


static NSString* const kRot90                   = @"90";
static NSString* const kRot180                  = @"180";
static NSString* const kRot270                  = @"270";
static NSString* const kRot0                    = @"0";
static NSInteger const kThumbnailTimestamp      = 1;
static float     const kCroppedImageDimension   = 320.0;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWMediaPickerController

@synthesize cameraOverlayViewController     = _cameraOverlayViewController;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate {
    self = [super init];
    
    if(self) {
        _mediaDelegate = theDelegate;
        self.cameraOverlayViewController = [[[DWCameraOverlayViewController alloc] 
                                             initWithDelegate:self] autorelease];
    }
    
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (NSString*)extractOrientationOfVideo:(NSURL*)videoURL {
	/**
	 * Extracts the orientation of the video using AVFoundation
	 */
	NSString *orientation		= nil;
	AVURLAsset *avAsset			= [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	AVAssetTrack* videoTrack	= [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	CGAffineTransform txf		= [videoTrack preferredTransform];
	[avAsset release];
	
	if(txf.a == 0 && txf.b == 1 && txf.c == -1 && txf.d == 0)
		orientation = kRot90;
	else if(txf.a == -1 && txf.b == 0 && txf.c == 0 && txf.d == -1)
		orientation = kRot180;
	else if(txf.a == 0 && txf.b == -1 && txf.c == 1 && txf.d == 0)
		orientation = kRot270;
	else if(txf.a == 1 && txf.b == 0 && txf.c == 0 && txf.d == 1)
		orientation = kRot0;
	
	return orientation;
}

//----------------------------------------------------------------------------------------------------
- (UIImage*)extractThumbnailFromVideo:(NSURL*)videoURL 
						atOrientation:(NSString*)orientation {
	
	/**
	 * Extract thumbnail from the video and rotate it based
	 * upon the provided orientation
	 */
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL
												options:nil];
	
	AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	
	[asset release];
	
	NSError *err		= nil;
	CMTime time			= CMTimeMake(kThumbnailTimestamp, 60);
	
	CGImageRef imgRef	= [generate copyCGImageAtTime:time 
										   actualTime:NULL
												error:&err];
	
	[generate release];
	
	
	UIImage				*result				= nil;
	UIImageOrientation	imageOrientation	= UIImageOrientationUp;
	
	if(!err) {
		if([orientation isEqualToString:kRot0]) {
			
			result = [UIImage imageWithCGImage:imgRef];
		}
		else if([orientation isEqualToString:kRot90]) {
			
			result = [UIImage imageWithCGImage:imgRef 
										 scale:1.0
								   orientation:UIImageOrientationRight];
			
			imageOrientation = UIImageOrientationRight;
		}
		else if([orientation isEqualToString:kRot180]) {
			
			result = [UIImage imageWithCGImage:imgRef 
										 scale:1.0
								   orientation:UIImageOrientationDown];
			
			imageOrientation = UIImageOrientationDown;
		}
		else if([orientation isEqualToString:kRot270]) {
			
			result = [UIImage imageWithCGImage:imgRef 
										 scale:1.0
								   orientation:UIImageOrientationLeft];
			
			imageOrientation = UIImageOrientationLeft;
		}
	}
	
	return [result cropToRect:CGRectMake(0,(result.size.height - result.size.width)/2,
										 result.size.width,
										 result.size.width)
			  withOrientation:imageOrientation];
}

//----------------------------------------------------------------------------------------------------
- (void)prepare:(NSInteger)pickerMode {
    self.delegate                   = self;
    self.sourceType                 = pickerMode;
    
    if (pickerMode == kMediaPickerCaptureMode) {
        self.cameraOverlayView          = self.cameraOverlayViewController.view;
        self.showsCameraControls        = NO;
        self.cameraFlashMode            = UIImagePickerControllerCameraFlashModeOff;
    }
    else
        self.allowsEditing              = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForImageWithPickerMode:(NSInteger)pickerMode {
	[self prepare:pickerMode];
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForMediaWithPickerMode:(NSInteger)pickerMode {
	[self prepare:pickerMode];
    
    self.mediaTypes					= [UIImagePickerController availableMediaTypesForSourceType:
																self.sourceType];   
    self.videoMaximumDuration		= kMaxVideoDuration;
    self.videoQuality				= UIImagePickerControllerQualityTypeMedium;
}

//----------------------------------------------------------------------------------------------------
- (void) dealloc {	
	self.cameraOverlayViewController = nil;
    
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIImagePickerControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSURL *mediaURL = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
	
	if(!mediaURL) {
		UIImage *originalImage	= [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage *resizedImage   = nil; 
        UIImage *editedImage    = nil;
        
        if (picker.sourceType == kMediaPickerCaptureMode) {
            if(originalImage.size.width > originalImage.size.height) {
                resizedImage    = [originalImage resizeTo:
                                   CGSizeMake(originalImage.size.width * 
                                              kCroppedImageDimension/originalImage.size.height,
                                              kCroppedImageDimension)];
                 editedImage    = [resizedImage cropToRect:
                                   CGRectMake((int)((resizedImage.size.width - kCroppedImageDimension)/2), 0, 
                                              kCroppedImageDimension, kCroppedImageDimension)];
            }
            else {
                resizedImage    = [originalImage resizeTo:
                                   CGSizeMake(kCroppedImageDimension,
                                              originalImage.size.height * 
                                              kCroppedImageDimension/originalImage.size.width)];
                editedImage     = [resizedImage cropToRect:
                                   CGRectMake(0,(int)((resizedImage.size.height - kCroppedImageDimension)/2), 
                                              kCroppedImageDimension, kCroppedImageDimension)];
            }
                
			UIImageWriteToSavedPhotosAlbum(originalImage, self, 
                                           @selector(image:didFinishSavingWithError:contextInfo:), 
                                           nil);
        }
        else {
            editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        }
		
		[_mediaDelegate didFinishPickingImage:originalImage 
								  andEditedTo:editedImage];
	}
	else {
		NSString *orientation = [self extractOrientationOfVideo:mediaURL];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], self, 
                                                @selector(video:didFinishSavingWithError:contextInfo:), 
                                                nil);
		
		[_mediaDelegate didFinishPickingVideoAtURL:mediaURL
								   withOrientation:orientation
										andPreview:[self extractThumbnailFromVideo:mediaURL 
																	 atOrientation:orientation]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   [_mediaDelegate mediaPickerCancelledFromMode:picker.sourceType];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWCameraOverlayViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)cameraButtonClickedInOverlayView {
    [self takePicture];
}

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClickedInOverlayView {
    [_mediaDelegate mediaPickerCancelledFromMode:kMediaPickerCaptureMode];
}

//----------------------------------------------------------------------------------------------------
- (void)flashModeChangedInOverlayView:(NSInteger)cameraFlashMode {
    self.cameraFlashMode = cameraFlashMode;
}
 
//----------------------------------------------------------------------------------------------------
- (void)cameraDeviceChangedInOverlayView:(NSInteger)cameraDevie {
    self.cameraDevice = cameraDevie;
}

//----------------------------------------------------------------------------------------------------
- (void)photoLibraryButtonClickedInOverlayView {
    [_mediaDelegate photoLibraryModeSelected];
}

//----------------------------------------------------------------------------------------------------
- (void)startRecording {
    [self startVideoCapture];
    [self.cameraOverlayViewController displayRecordingTimer];
}

//----------------------------------------------------------------------------------------------------
- (void)stopRecording {
    [self stopVideoCapture];
}

//----------------------------------------------------------------------------------------------------
- (void)cameraCaptureModeChangedInOverlayView:(NSInteger)cameraCaptureMode {
    self.cameraCaptureMode = cameraCaptureMode;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Selectors fired when image or video is saved to disk

//----------------------------------------------------------------------------------------------------
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo {

}

//----------------------------------------------------------------------------------------------------
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {

}

@end
