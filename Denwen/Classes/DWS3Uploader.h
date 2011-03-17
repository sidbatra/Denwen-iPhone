//
//  DWS3Uploader.h
//  Denwen
//
//  Created by Siddharth Batra on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWURLConnection.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@protocol DWS3UploaderDelegate;

@interface DWS3Uploader : NSObject<ASIHTTPRequestDelegate> {
	ASIFormDataRequest *_asiRequest;
	NSMutableString *_filename;

	id <DWS3UploaderDelegate> _delegate;
}

- (void)uploadImage:(UIImage*)image toFolder:(NSString*)folder;
- (void)uploadVideo:(NSData*)videoData atOrientation:(NSString*)orientation toFolder:(NSString*)folder;


@property (retain) NSMutableString *filename;
@property (retain) ASIFormDataRequest *asiRequest;

@end


@protocol DWS3UploaderDelegate
- (void)finishedUploadingMedia:(NSString*)filename;
- (void)errorUploadingMedia:(NSError*)error;
@end

