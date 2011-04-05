//
//  DWImagePicker.m
//  Denwen
//
//  Created by Deepak Rao on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWImagePicker.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"
#import "DWRequestsManager.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWImagePicker

@synthesize imagePickerController=_imagePickerController;


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
	NSString *orientation = nil;
	AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	AVAssetTrack* videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	CGAffineTransform txf = [videoTrack preferredTransform];
	[avAsset release];
	
	if(txf.a == 0 && txf.b == 1 && txf.c == -1 && txf.d == 0)
		orientation = [NSString stringWithString:@"90"];
	else if(txf.a == -1 && txf.b == 0 && txf.c == 0 && txf.d == -1)
		orientation = [NSString stringWithString:@"180"];
	else if(txf.a == 0 && txf.b == -1 && txf.c == 1 && txf.d == 0)
		orientation = [NSString stringWithString:@"270"];
	else if(txf.a == 1 && txf.b == 0 && txf.c == 0 && txf.d == 1)
		orientation = [NSString stringWithString:@"0"];
	
	return orientation;
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForImage:(NSInteger)type {
    self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    self.imagePickerController.sourceType =  type == 0 ? UIImagePickerControllerSourceTypeCamera :UIImagePickerControllerSourceTypePhotoLibrary;
}

//----------------------------------------------------------------------------------------------------
- (void)prepareForMedia:(NSInteger)type {
    [self prepareForImage:type];
    self.imagePickerController.mediaTypes = [UIImagePickerController  
                                        availableMediaTypesForSourceType:self.imagePickerController.
                                        sourceType];   
    self.imagePickerController.videoMaximumDuration = VIDEO_MAX_DURATION;
    self.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
}

//----------------------------------------------------------------------------------------------------
- (void) dealloc {
    self.imagePickerController = nil;
    [super dealloc];
}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ImagePickerController Delegate

//----------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo
                             :(NSDictionary *)info {
    
    UIImage *previewImage = nil;
	NSURL *mediaURL = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
	BOOL isImageFile = mediaURL == nil;
    NSInteger uploadID;
	
	
	if(isImageFile) {
		UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
		UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
		
		previewImage = [image resizeTo:
                        CGSizeMake(SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE,SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE)];
		
		uploadID = [[DWRequestsManager sharedDWRequestsManager] createImageWithData:image 
                                                                           toFolder:S3_ITEMS_FOLDER];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UIImageWriteToSavedPhotosAlbum(originalImage, self, 
                                           @selector(image:didFinishSavingWithError:contextInfo:), 
                                           nil);
	}
	else {
		NSString *orientation = [self extractOrientationOfVideo:mediaURL];
		
		previewImage = [UIImage imageNamed:VIDEO_TINY_PREVIEW_PLACEHOLDER_IMAGE_NAME];
		
		uploadID = [[DWRequestsManager sharedDWRequestsManager] createVideoUsingURL:mediaURL 
                                                                      atOrientation:orientation
                                                                           toFolder:S3_ITEMS_FOLDER];
		
		if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
			UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], self, 
                                                @selector(video:didFinishSavingWithError:contextInfo:), 
                                                nil);
	}
    
    [_delegate mediaPickedAndProcessedWithID:uploadID andPreview:previewImage];
}

//----------------------------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_delegate mediaCancelled];
}

//----------------------------------------------------------------------------------------------------
- (void)image:(UIImage *)image didFinishSavingWithError
             :(NSError *)error contextInfo:(void *)contextInfo {
    //TODO
}

//----------------------------------------------------------------------------------------------------
- (void)video:(NSString *)videoPath didFinishSavingWithError
             :(NSError *)error contextInfo:(void *)contextInfo {
    //TODO
}



@end
