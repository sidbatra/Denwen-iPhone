//
//  DWCreationQueueItem.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Base class for all items added onto the 
 * creation queue
 */
@interface DWCreationQueueItem : NSObject {
	NSInteger	_mediaUploadID;
	NSInteger	_primaryUploadID;
	
	float		_progress;
	
	NSInteger	_mediaUploadRetries;
	NSInteger	_primaryUploadRetries;
	
	NSInteger	_state;
    
    BOOL        _isSilent;
	
	NSString	*_filename;
	NSString	*_errorMessage;
}

/**
 * State of the item on the queue
 */
@property (nonatomic,readonly) NSInteger state;

/**
 * Upload progress for both the uploads
 */
@property (nonatomic,readonly) float progress;

/**
 * Generic filename, mainly used for storing filenames
 * of media attachments
 */
@property (nonatomic,retain) NSString* filename;

/**
 * Error message optionally specifies the reason
 * for a media or primary upload failure
 */ 
@property (nonatomic,retain) NSString* errorMessage;

/**
 * YES if either of the upload is in progress
 */
- (BOOL)isActive;

/**
 * YES if either of the uploads has failed
 */
- (BOOL)isFailed;

/**
 * Fires a notification whenever the uploading makes progress
 */
- (void)postUpdate;

/**
 * Stub for upload media to the server. Usually this is
 * a secondary upload followed by the primary upload
 * that is dependant on the media being uploaded
 */
- (void)startMediaUpload;

/**
 * Stub for the primary method to upload data 
 */
- (void)startPrimaryUpload;

/**
 * Stub for starting or resuming the creation process 
 */
- (void)start;

/**
 * Stub. Called when media upload successfully finishes
 */
- (void)mediaUploadFinished:(NSString*)theFilename;

/**
 * Stub. Called when media upload fails
 */
- (void)mediaUploadError;

/**
 * Stub. Called when primary upload finished successfully
 */
- (void)primaryUploadFinished;

/**
 * Stub. Called when primary upload fails
 */
- (void)primaryUploadError;

@end