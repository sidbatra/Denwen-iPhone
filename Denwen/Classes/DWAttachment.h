//
//  DWAttachment.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Attachment model represents media entities attached to
 * a post - as defined in the database
 */
@interface DWAttachment : NSObject {
	NSString		*_previewURL;
	NSString		*_fileURL;
	NSString		*_orientation;
	NSURL			*_videoURL;
	
	NSInteger		_databaseID;
	NSInteger		_fileType;
	
	BOOL			_isProcessed;
	BOOL			_isDownloading;
	
	UIImage			*_previewImage;
}

/**
 * Primary key value in the database
 */
@property (nonatomic,readonly) NSInteger databaseID;

/**
 * Filetype for the attachment - image or video
 */
@property (nonatomic,assign) NSInteger fileType;

/**
 * URL of the actual attachment
 */
@property (nonatomic,copy) NSString *fileURL;

/**
 * URL of the preview image - either a image preview
 * or a video thumbnail
 */
@property (nonatomic,copy) NSString *previewURL;

/**
 * Orientation for a video attachment
 */
@property (nonatomic,copy) NSString* orientation;

/**
 * Media URL for a video attachment
 */
@property (nonatomic,retain) NSURL *videoURL;

/**
 * Preview image downloaded from previewURL
 */
@property (nonatomic,retain) UIImage *previewImage;

/**
 * Populate the object using a JSON dictionary
 */
- (void)populate:(NSDictionary*)attacment;

/**
 * Update the object using a JSON dictionary
 */
- (void)update:(NSDictionary*)attachment;

/**
 * Start downloading the image at previewURL
 */
- (void)startPreviewDownload;

/**
 * Is the attachment a vide
 */
- (BOOL)isVideo;

/**
 * Is the attachment an image
 */
- (BOOL)isImage;

/**
 * Free non critical objects
 */
- (void)freeMemory;

@end

