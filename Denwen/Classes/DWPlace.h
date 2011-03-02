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
#import "DWURLConnection.h"
#import "DWImageHelper.h"
#import "Constants.h"


@interface DWPlace : DWPoolObject <DWURLConnectionDelegate> {
	NSString *_name;
	NSString *_hashedId;
	
	NSString *_town;
	NSString *_state;
	NSString *_country;
	
	NSString *_smallURL;
	NSString *_mediumURL;
	NSString *_largeURL;
	
	CLLocation *_location;

	UIImage *_smallPreviewImage;
	UIImage *_mediumPreviewImage;
	UIImage *_largePreviewImage;
	
	BOOL _isSmallDownloading;
	BOOL _isMediumDownloading;
	BOOL _isLargeDownloading;

	BOOL _forceSmallDownloading;
	BOOL _forceMediumDownloading;
	BOOL _forceLargeDownloading;
	
	BOOL _hasPhoto;
	BOOL _hasAddress;
	BOOL _isProcessed;
	
	DWURLConnection *_smallConnection;
	DWURLConnection *_mediumConnection;
	DWURLConnection *_largeConnection;

}

//Initialization

//Update 
- (void)updatePreviewURLs:(NSDictionary*)place;
- (void)updatePreviewImages:(UIImage*)image;


//Functions for handling server interactions 
- (void)startSmallPreviewDownload;
- (void)startMediumPreviewDownload;
- (void)startLargePreviewDownload;


//Caching helper functions
- (NSString*)smallUniqueKey;
- (NSString*)mediumUniqueKey;
- (NSString*)largeUniqueKey;

- (NSString*)displayAddress;

@property (copy) NSString *name;
@property (copy) NSString *hashedId;

@property (copy) NSString *town;
@property (copy) NSString *state;
@property (copy) NSString *country;

@property (copy) NSString *smallURL;
@property (copy) NSString *mediumURL;
@property (copy) NSString *largeURL;

@property (copy) CLLocation *location;

@property (retain) UIImage *smallPreviewImage;
@property (retain) UIImage *mediumPreviewImage;
@property (retain) UIImage *largePreviewImage;

@property (retain) DWURLConnection *smallConnection;
@property (retain) DWURLConnection *mediumConnection;
@property (retain) DWURLConnection *largeConnection;


@property (readonly) BOOL hasPhoto;

@end


