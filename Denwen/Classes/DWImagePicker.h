//
//  DWImagePicker.h
//  Copyright 2011 Denwen. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "DWConstants.h"
#import "DWRequestsManager.h"
#import "DWVideoHelper.h"

@protocol DWImagePickerDelegate;

/**
 * Wrapper for UIImagePickerController
 */
@interface DWImagePicker : NSObject <UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    UIImagePickerController *_imagePickerController;
    id <DWImagePickerDelegate>	_delegate;
}

/**
 * ImagePickerController for the modal view
 */
@property (nonatomic,retain) UIImagePickerController *imagePickerController;


/**
 * Init with delegate to implement the events from imagePickerController
 */
- (id)initWithDelegate:(id)delegate;

/**
 * Prepare the imagePickerController for media (image/video)
 */
- (void)prepareForMedia:(NSInteger)type;

/**
 * Prepare the imagePickerController for only images
 */
- (void)prepareForImage:(NSInteger)type;


@end


/**
 * Delegate protocol to receive updates of the all events
 * of the imagePickerController
 */
@protocol DWImagePickerDelegate

- (void)mediaPickedAndProcessedWithID:(NSInteger)uploadID andPreview:(UIImage*)previewImage;
- (void)mediaCancelled;

@end