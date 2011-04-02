//
//  DWImagePicker.m
//  Denwen
//
//  Created by Deepak Rao on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWImagePicker.h"
#import "UIImage+ImageProcessing.h"


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
		NSString *orientation = [DWVideoHelper extractOrientationOfVideo:mediaURL];
		
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
