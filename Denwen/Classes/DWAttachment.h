//
//  DWAttachment.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWURLConnection.h"
#import "DWImageHelper.h"
#import "Constants.h"



@interface DWAttachment : NSObject <DWURLConnectionDelegate> {
	NSString *_previewUrl;
	NSString *_fileUrl;
	
	NSInteger _databaseID;
	NSInteger _fileType;
	
	BOOL _isProcessed;
	BOOL _isDownloading;
	
	UIImage *_previewImage;
	
	DWURLConnection *_connection;
}


//Initialization

//Functions for handling server interactions 
- (void)populate:(NSDictionary*)result;
- (void)startPreviewDownload;

//Caching helper functions
- (NSString*)uniqueKey;
- (NSString*)uniquePreviewKey;

//Preview deciding functions
- (BOOL)hasRemoteImagePreview;
- (BOOL)isVideo;
- (BOOL)isImage;


//Memory management
- (void)freeMemory;


//Properties
@property (retain) UIImage *previewImage;
@property (retain) DWURLConnection *connection;
@property (copy) NSString *fileUrl;
@property (copy) NSString *previewUrl;


@end

