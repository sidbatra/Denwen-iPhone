//
//  DWMediaPickerController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWMediaPickerController.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"
#import "DWRequestsManager.h"


static NSString* const kRot90				= @"90";
static NSString* const kRot180				= @"180";
static NSString* const kRot270				= @"270";
static NSString* const kRot0				= @"0";
static NSInteger const kMaxVideoDuration	= 45;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWMediaPickerController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate {
    self = [super init];
    
    if(self) {
        _mediaDelegate = theDelegate;
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
- (void)prepare:(NSInteger)pickerMode allowsEditing:(BOOL)doesAllowEditing {
	
    self.delegate					= self;
	self.allowsEditing				= doesAllowEditing;
    self.sourceType					= pickerMode;
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForImageWithPickerMode:(NSInteger)pickerMode
						  withEditing:(BOOL)doesAllowEditing {
	
	[self prepare:pickerMode allowsEditing:doesAllowEditing];
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForMediaWithPickerMode:(NSInteger)pickerMode
						  withEditing:(BOOL)doesAllowEditing {
	
	[self prepare:pickerMode allowsEditing:doesAllowEditing];
	
    self.mediaTypes					= [UIImagePickerController availableMediaTypesForSourceType:
																self.sourceType];   
    self.videoMaximumDuration		= kMaxVideoDuration;
    self.videoQuality				= UIImagePickerControllerQualityTypeMedium;
}

//----------------------------------------------------------------------------------------------------
- (void) dealloc {		
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
		UIImage *editedImage	= [info valueForKey:UIImagePickerControllerEditedImage];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UIImageWriteToSavedPhotosAlbum(originalImage, self, 
                                           @selector(image:didFinishSavingWithError:contextInfo:), 
                                           nil);
		
		[_mediaDelegate didFinishPickingImage:originalImage 
								  andEditedTo:editedImage];
	}
	else {
		NSString *orientation = [self extractOrientationOfVideo:mediaURL];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], self, 
                                                @selector(video:didFinishSavingWithError:contextInfo:), 
                                                nil);
		
		
		/*AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:mediaURL options:nil];
		AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
		generator.appliesPreferredTrackTransform=TRUE;
		[asset release];
		
		CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
		
		UIImage *thumbImg = nil;
		
		AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
			if (result != AVAssetImageGeneratorSucceeded) {
				NSLog(@"couldn't generate thumbnail, error:%@", error);
			}
			//previewImage = [[UIImage imageWithCGImage:im] retain];
			//[button setImage:[UIImage imageWithCGImage:im] forState:UIControlStateNormal];
			thumbImg=[[UIImage imageWithCGImage:im] retain];
			[generator release];
		};
		
		CGSize maxSize = CGSizeMake(320, 180);
		generator.maximumSize = maxSize;
		[generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
		 */
		
		[_mediaDelegate didFinishPickingVideoAtURL:mediaURL
								   withOrientation:orientation
										andPreview:nil];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   [_mediaDelegate mediaPickerCancelled];
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
