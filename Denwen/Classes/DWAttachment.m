//
//  DWAttachment.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWAttachment.h"


@implementation DWAttachment

@synthesize previewImage=_previewImage,connection=_connection,fileUrl=_fileUrl,previewUrl=_previewUrl;



#pragma mark -
#pragma mark Initialization logic


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {		
		_isDownloading = NO;
	}
	
	return self;  
}



#pragma mark -
#pragma mark Server interaction methods


// Populate attachment attributes from JSON object
// parsed into a NSDictionary object
//
- (void)populate:(NSDictionary*)attachment {	
	_fileType = [[attachment objectForKey:@"filetype"] integerValue];
	_databaseID = [[attachment objectForKey:@"id"] integerValue];
	_isProcessed = [[attachment objectForKey:@"is_processed"] boolValue];
	
	self.fileUrl = [attachment objectForKey:@"actual_url"];
	self.previewUrl = [attachment objectForKey:@"large_url"];
}


//Start the attachment preview download
//
- (void)startPreviewDownload {
	if(!_isDownloading && !self.previewImage) {
		 _isDownloading = YES;
		
		DWURLConnection *tempConnection = [[DWURLConnection alloc] initWithDelegate:self];
		self.connection = tempConnection;
		[tempConnection release];
		
		[self.connection fetchData:self.previewUrl withKey:[self uniquePreviewKey] withCache:YES];
	}
}



#pragma mark -
#pragma mark URLConnection delegate


// Error while downloading data from the server. This also fires a delegate 
// error method which is handled by DWItem. 
//
- (void)errorLoadingData:(NSError *)error forInstanceID:(NSInteger)instanceID {
	self.connection = nil;
	_isDownloading = NO;
	//Handle or log error	
}


// If the data is successfully downloaded from the server. This also fires a 
// delegate success method which is handled by DWItem.
//
- (void)finishedLoadingData:(NSMutableData *)data forInstanceID:(NSInteger)instanceID {	
	
	UIImage *image = [[UIImage alloc] initWithData:data];

	self.previewImage = _isProcessed ? image : [DWImageHelper resizeImage:image 
																 scaledToSize:CGSizeMake(SIZE_ATTACHMENT_IMAGE, SIZE_ATTACHMENT_IMAGE)];

	[image release];
	
	_isDownloading = NO;

	[[NSNotificationCenter defaultCenter] postNotificationName:N_ATTACHMENT_PREVIEW_DONE object:self];	
	self.connection = nil;
}



#pragma mark -
#pragma mark Caching helper functions


// Create and return a unique key for the primary file
//
- (NSString*)uniqueKey {
	NSArray *listItems = [self.fileUrl componentsSeparatedByString:@"/"];
	return [[[NSString alloc] initWithFormat:@"%@",[listItems objectAtIndex:[listItems count]-1]] autorelease];
}


// Create and return a unique key for the preview of the file
//
- (NSString*)uniquePreviewKey {
	NSArray *listItems = [self.previewUrl componentsSeparatedByString:@"/"];
	return [[[NSString alloc] initWithFormat:@"%@",[listItems objectAtIndex:[listItems count]-1]] autorelease];
}



#pragma mark -
#pragma mark Preview Deciding functions


// Returns whether the upload requires an image preview from a
// remote server
//
- (BOOL)hasRemoteImagePreview {
	return _fileType == IMAGE || _fileType == VIDEO;
}


// Returns whether the upload needs a text preview
//
- (BOOL)hasVideoPreview {
	return _fileType == VIDEO;
}



#pragma mark -
#pragma mark Memory Management


// Release the preview image
//
- (void)freeMemory {
	self.previewImage = nil;
}


// Usual Memory Cleanup
// 
-(void)dealloc{
	
	if(self.connection) {
		[self.connection cancel];
		self.connection = nil;
	}
		
	self.fileUrl = nil;
	self.previewUrl = nil;
	self.previewImage = nil;
	
	[super dealloc];
}

@end
