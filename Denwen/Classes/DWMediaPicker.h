//
//  DWMediaPicker.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol DWMediaPickerDelegate;

/**
 * Wrapper for UIImagePickerController
 */
@interface DWMediaPicker : NSObject <UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
	
    UIImagePickerController		*_imagePickerController;
    id <DWMediaPickerDelegate>	_delegate;
}

/**
 * Apple's ImagePickerController for selecting and capturing media
 */
@property (nonatomic,retain) UIImagePickerController *imagePickerController;


/**
 * Init with delegate to capture media picker events
 */
- (id)initWithDelegate:(id)delegate;

/**
 * Prepare the imagePickerController for media (image & video)
 */
- (void)prepareForMediaWithPickerMode:(NSInteger)pickingMode 
						   withEditing:(BOOL)allowsEditing;

/**
 * Prepare the imagePickerController for images
 */
- (void)prepareForImageWithPickerMode:(NSInteger)pickingMode
						   withEditing:(BOOL)allowsEditing;


@end


/**
 * Delegate protocol to receive updates events
 * during the media picker lifecycle
 */
@protocol DWMediaPickerDelegate

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
