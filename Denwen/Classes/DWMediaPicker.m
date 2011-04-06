//
//  DWMediaPicker.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWMediaPicker.h"
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
@implementation DWMediaPicker

@synthesize imagePickerController = _imagePickerController;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
    self = [super init];
    
    if(self != nil) {
        _delegate = delegate;
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
- (void)prepare:(NSInteger)pickerMode allowsEditing:(BOOL)allowsEditing {
	
	self.imagePickerController					= [[[UIImagePickerController alloc] init] autorelease];
    self.imagePickerController.delegate			= self;
	self.imagePickerController.allowsEditing	= allowsEditing;
    self.imagePickerController.sourceType		= pickerMode;
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForImageWithPickerMode:(NSInteger)pickerMode
						   withEditing:(BOOL)allowsEditing {
	
	[self prepare:pickerMode allowsEditing:allowsEditing];
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForMediaWithPickerMode:(NSInteger)pickerMode
						   withEditing:(BOOL)allowsEditing {
	
    [self prepare:pickerMode allowsEditing:allowsEditing];
	
    self.imagePickerController.mediaTypes			= [UIImagePickerController availableMediaTypesForSourceType:
															self.imagePickerController.sourceType];   
    self.imagePickerController.videoMaximumDuration = kMaxVideoDuration;
    self.imagePickerController.videoQuality			= UIImagePickerControllerQualityTypeMedium;
}

//----------------------------------------------------------------------------------------------------
- (void) dealloc {
    self.imagePickerController = nil;
	
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
		
		[_delegate didFinishPickingImage:originalImage andEditedTo:editedImage];
	}
	else {
		NSString *orientation = [self extractOrientationOfVideo:mediaURL];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], self, 
                                                @selector(video:didFinishSavingWithError:contextInfo:), 
                                                nil);
		
		[_delegate didFinishPickingVideoAtURL:mediaURL withOrientation:orientation];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_delegate mediaPickerCancelled];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Selectors fired when saving images and video to disk

//----------------------------------------------------------------------------------------------------
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo {

}

//----------------------------------------------------------------------------------------------------
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {

}

@end
