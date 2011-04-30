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
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
	}
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
-(void)presentMediaPickerControllerForPickerMode:(NSInteger)pickerMode {
    [[DWMemoryPool sharedDWMemoryPool] freeMemory];
    
    DWMediaPickerController *picker = [[[DWMediaPickerController alloc] initWithDelegate:self] autorelease];
    [picker prepareForImageWithPickerMode:pickerMode];
    [[_delegate requestController] presentModalViewController:picker animated:NO];   
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
    
	[[DWSession sharedDWSession].currentUser updatePreviewImages:editedImage];
    [_delegate photoPicked:editedImage];
}

//----------------------------------------------------------------------------------------------------
- (void)mediaPickerCancelledFromMode:(NSInteger)imagePickerMode {    
    [[_delegate requestController] dismissModalViewControllerAnimated:NO];  
    
    if (imagePickerMode == kMediaPickerLibraryMode)
        [self presentMediaPickerControllerForPickerMode:kMediaPickerCaptureMode];
}

//----------------------------------------------------------------------------------------------------
- (void)photoLibraryModeSelected {
    [[_delegate requestController] dismissModalViewControllerAnimated:NO];
    [self presentMediaPickerControllerForPickerMode:kMediaPickerLibraryMode];
}

@end
