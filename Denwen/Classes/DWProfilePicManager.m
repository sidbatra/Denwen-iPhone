//
//  DWPicManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWProfilePicManager.h"
#import "DWCreationQueue.h"
#import "DWConstants.h"
#import "DWMemoryPool.h"
#import "DWSession.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWProfilePicManager

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate andPickerMode:(NSInteger)pickerMode {
	self = [super init];
	
	if(self != nil) {
		_delegate               = delegate;
        _initialImagePickerMode = pickerMode;
	}
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
-(void)presentMediaPickerControllerForPickerMode:(NSInteger)pickerMode withPreview:(BOOL)preview {
    [[DWMemoryPool sharedDWMemoryPool] freeMemory];
    
    DWMediaPickerController *picker = [[[DWMediaPickerController alloc] initWithDelegate:self] autorelease];
    [picker prepareForImageWithPickerMode:pickerMode withPreview:preview];
    [[_delegate requestController] presentModalViewController:picker animated:NO];   
}

//----------------------------------------------------------------------------------------------------
-(void)presentMediaPickerControllerWithPreview:(BOOL)preview {
    [self presentMediaPickerControllerForPickerMode:_initialImagePickerMode withPreview:preview];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWMediaPickerControllerDelegate
//----------------------------------------------------------------------------------------------------
- (void)didFinishPickingImage:(UIImage*)originalImage 
				  andEditedTo:(UIImage*)editedImage {
	
	[[_delegate requestController] dismissModalViewControllerAnimated:NO];
        
    [[DWCreationQueue sharedDWCreationQueue] 
            addNewUpdateUserPhotoToQueueWithUserID:[DWSession sharedDWSession].currentUser.databaseID
                                          andImage:editedImage];
    
    [_delegate photoPicked];
}

//----------------------------------------------------------------------------------------------------
- (void)mediaPickerCancelledFromMode:(NSInteger)imagePickerMode {    
    [[_delegate requestController] dismissModalViewControllerAnimated:NO];  
    
    if (imagePickerMode == kMediaPickerLibraryMode  && _initialImagePickerMode == kMediaPickerCaptureMode)
        [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode withPreview:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)photoLibraryModeSelected {
    [[_delegate requestController] dismissModalViewControllerAnimated:NO];
    [self presentMediaPickerControllerForPickerMode:kMediaPickerLibraryMode withPreview:YES];
}

@end
