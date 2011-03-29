//
//  DWS3Uploader.m
//  Denwen
//
//  Created by Siddharth Batra on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWS3Uploader.h"


@interface DWS3Uploader() 
- (void)cancel;
- (void)uploadMedia:(NSData*)data toFolder:(NSString*)folder withContentType:(NSString*)contentType andSuffix:(NSString*)suffix;
@end



@implementation DWS3Uploader

@synthesize asiRequest=_asiRequest,filename=_filename;


// Init the class along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
	}
	
	return self;  
}


// Generic method to upload media to the S3 server
//
- (void)uploadMedia:(NSData*)data toFolder:(NSString*)folder withContentType:(NSString*)contentType andSuffix:(NSString*)suffix {
	[self cancel];
	
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
	
	NSMutableString *tempFilename = [[NSMutableString alloc] initWithFormat:@"%0.0f_",timestamp];
	self.filename = tempFilename;
	[tempFilename release];
	
	
	for(int i=0;i<20;i++)
		[self.filename appendFormat:@"%d",arc4random() % 10];
	
	[self.filename appendString:suffix];

	
	
	NSURL *url = [[NSURL alloc] initWithString:S3_SERVER];
	
	ASIFormDataRequest *tempRequest = [[ASIFormDataRequest alloc] initWithURL:url];
	self.asiRequest = tempRequest;
	[url release];
	[tempRequest release];
	
	self.asiRequest.delegate = self;
	//[ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
	
	[self.asiRequest setShouldStreamPostDataFromDisk:YES];

	[self.asiRequest setPostValue:S3_UPLOAD_POLICY forKey:@"policy"];
	[self.asiRequest setPostValue:S3_UPLOAD_SIGNATURE forKey:@"signature"];
	[self.asiRequest setPostValue:S3_ACCESS_ID forKey:@"AWSAccessKeyId"];
	[self.asiRequest setPostValue:S3_ACL forKey:@"acl"];
	[self.asiRequest setPostValue:[[[NSString alloc] initWithFormat:@"%@/${filename}",folder] autorelease] forKey:@"key"];
	
	[self.asiRequest setData:data withFileName:self.filename andContentType:contentType forKey:@"file"];
	
	[self.asiRequest startAsynchronous];	
}


// Upload the given image to the given S3 folder
//
- (void)uploadImage:(UIImage*)image toFolder:(NSString*)folder {
	[self uploadMedia:UIImageJPEGRepresentation(image,JPEG_COMPRESSION) toFolder:folder withContentType:@"image/jpeg" andSuffix:@"_photo.jpg"];
}


// Upload the given video bytes to the given S3 folder
//
- (void)uploadVideo:(NSData*)videoData atOrientation:(NSString*)orientation toFolder:(NSString*)folder {
	[self uploadMedia:videoData 
			 toFolder:folder 
	  withContentType:@"video/quicktime" 
			andSuffix:[NSString stringWithFormat:@"_video_o_%@.mov",orientation]
	 ];
}


// Cancel any existing uploads
//
- (void)cancel {
	if(self.asiRequest) {
		[self.asiRequest clearDelegatesAndCancel];
		self.asiRequest = nil;
	}
}



#pragma mark -
#pragma mark ASIHTTPRequestDelegate


// Fired when the ASI request is successfully finished
//
- (void)requestFinished:(ASIHTTPRequest *)request {
	//NSString *responseString = [request responseString];
	
	self.asiRequest = nil;
	
	[_delegate finishedUploadingMedia:self.filename];
}


// Fired when there is an error in the ASI request
//
- (void)requestFailed:(ASIHTTPRequest *)request {
	self.asiRequest = nil;
	
	[_delegate errorUploadingMedia:[request error]];
}



#pragma mark -
#pragma mark Memory management


// The usual cleanup
//
- (void)dealloc {
	
	[self cancel];
	self.filename = nil;
	
	_delegate = nil;
	
	[super dealloc];
}


@end
