//
//  DWUser.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "DWPoolObject.h"
#import "DWRequestManager.h"
#import "DWURLConnection.h"
#import "DWImageHelper.h"
#import "DWURLHelper.h"
#import "DWUserLocation.h"
#import "Constants.h"



@interface DWUser : DWPoolObject <DWURLConnectionDelegate,DWRequestManagerDelegate> {
	NSString *_firstName;
	NSString *_lastName;
	NSString *_email;
	NSString *_encryptedPassword;
	NSString *_smallURL;
	NSString *_mediumURL;
	NSString *_largeURL;
	NSString *_twitterOAuthData;
	NSString *_facebookAccessToken;
	
	UIImage *_smallPreviewImage;
	UIImage *_mediumPreviewImage;
	
	BOOL _isSmallDownloading;
	BOOL _isMediumDownloading;
	BOOL _forceSmallDownloading;
	BOOL _forceMediumDownloading;
	BOOL _hasPhoto;
	BOOL _isProcessed;
	
	DWURLConnection *_smallConnection;
	DWURLConnection *_mediumConnection;
	
	DWRequestManager *_updateRequestManager;
	DWRequestManager *_updateTwitterDataRequestManager;
	DWRequestManager *_updateFacebookTokenRequestManager;
	DWRequestManager *_visitRequestManager;
	DWRequestManager *_updateUnreadRequestManager;
}


//Initialization

//Update 
- (void)updatePreviewURLs:(NSDictionary*)place;
- (void)updatePreviewImages:(UIImage*)image;
- (void)updateDeviceID:(NSString*)deviceID;
- (void)updateTwitterData;
- (void)updateUnreadCount:(NSInteger)subtrahend;

- (void)createVisit;

//Functions for handling server interactions 
- (void)startSmallPreviewDownload;
- (void)startMediumPreviewDownload;

- (void)storeTwitterData:(NSString *)data;
- (void)storeFacebookToken:(NSString *)token;


// Functions to manager saving & removing current user information to disk
- (void)saveToDisk;
- (BOOL)readFromDisk;
- (void)removeFromDisk;
- (void)print;

//Caching helper functions
- (NSString*)smallUniqueKey;
- (NSString*)mediumUniqueKey;
- (NSString*)largeUniqueKey;

//View helper functions
- (NSString*)fullName;

@property (copy) NSString * firstName;
@property (copy) NSString * lastName;
@property (copy) NSString * email;
@property (copy) NSString * encryptedPassword;
@property (copy) NSString *smallURL;
@property (copy) NSString *mediumURL;
@property (copy) NSString *largeURL;
@property (copy) NSString *twitterOAuthData;
@property (copy) NSString *facebookAccessToken;


@property (retain) UIImage *smallPreviewImage;
@property (retain) UIImage *mediumPreviewImage;

@property (retain) DWURLConnection *smallConnection;
@property (retain) DWURLConnection *mediumConnection;

@property (retain) DWRequestManager *updateRequestManager;
@property (retain) DWRequestManager *updateTwitterDataRequestManager;
@property (retain) DWRequestManager *updateFacebookTokenRequestManager;
@property (retain) DWRequestManager *visitRequestManager;
@property (retain) DWRequestManager *updateUnreadRequestManager;


@property (readonly) BOOL hasPhoto;

@end

