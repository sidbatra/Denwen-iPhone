//
//  DWMediaPickerController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol DWMediaPickerControllerDelegate;

/**
 * Wrapper for UIImagePickerController
 */
@interface DWMediaPickerController : UIImagePickerController <UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	
    id <DWMediaPickerControllerDelegate>	_mediaDelegate;
}

/**
 * Init with delegate to capture media picker events
 */
- (id)initWithDelegate:(id)theDelegate;

/**
 * Prepare the imagePickerController for media (image & video)
 */
- (void)prepareForMediaWithPickerMode:(NSInteger)pickingMode 
						  withEditing:(BOOL)doesAllowEditing;

/**
 * Prepare the imagePickerController for images
 */
- (void)prepareForImageWithPickerMode:(NSInteger)pickingMode
						  withEditing:(BOOL)doesAllowEditing;

@end


/**
 * Delegate protocol to receive updates events
 * during the media picker lifecycle
 */
@protocol DWMediaPickerControllerDelegate

@required

/**
 * Fired when an image is successfully picked. 
 */
- (void)didFinishPickingImage:(UIImage*)originalImage 
				  andEditedTo:(UIImage*)editedImage;

@optional

/**
 * Fired when a video is successfully picked
 */
- (void)didFinishPickingVideoAtURL:(NSURL*)videoURL
				   withOrientation:(NSString*)orientation;

/**
 * Fired when media picking is cancelled
 */
- (void)mediaPickerCancelled;

@end
