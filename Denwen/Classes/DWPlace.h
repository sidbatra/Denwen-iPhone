//
//  DWPlace.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#import "DWPoolObject.h"
#import "UIImage+ImageProcessing.h"
#import "Constants.h"


@interface DWPlace : DWPoolObject {
	NSString *_name;
	NSString *_hashedId;
	NSInteger _followersCount;
	
	NSString *_town;
	NSString *_state;
	NSString *_country;
	
	NSString *_smallURL;
	NSString *_largeURL;
	
	CLLocation *_location;

	UIImage *_smallPreviewImage;
	UIImage *_largePreviewImage;
	
	BOOL _isSmallDownloading;
	BOOL _isLargeDownloading;
	
	BOOL _hasPhoto;
	BOOL _hasAddress;
	BOOL _isProcessed;
}

//Initialization

//Update 
- (void)updatePreviewURLs:(NSDictionary*)place;
- (void)updatePreviewImages:(UIImage*)image;
- (void)updateFollowerCount:(NSInteger)delta;

//Functions for handling server interactions 
- (void)startSmallPreviewDownload;
- (void)startLargePreviewDownload;


- (NSString*)displayAddress;
- (NSString*)titleText;

@property (copy) NSString *name;
@property (copy) NSString *hashedId;

@property (copy) NSString *town;
@property (copy) NSString *state;
@property (copy) NSString *country;

@property (copy) NSString *smallURL;
@property (copy) NSString *largeURL;

@property (copy) CLLocation *location;

@property (retain) UIImage *smallPreviewImage;
@property (retain) UIImage *largePreviewImage;


@property (readonly) BOOL hasPhoto;

@end


