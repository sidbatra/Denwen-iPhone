//
//  DWAttachment.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"



@interface DWAttachment : NSObject {
	NSString *_previewUrl;
	NSString *_fileUrl;
	
	NSInteger _databaseID;
	NSInteger _fileType;
	
	BOOL _isProcessed;
	BOOL _isDownloading;
	
	UIImage *_previewImage;
}


//Initialization

//Functions for handling server interactions 
- (void)populate:(NSDictionary*)result;
- (void)update:(NSDictionary*)objectJSON;
- (void)startPreviewDownload;

//Preview deciding functions
- (BOOL)hasRemoteImagePreview;
- (BOOL)isVideo;
- (BOOL)isImage;


//Memory management
- (void)freeMemory;


//Properties
@property (nonatomic,readonly) NSInteger databaseID;
@property (retain) UIImage *previewImage;
@property (copy) NSString *fileUrl;
@property (copy) NSString *previewUrl;


@end

