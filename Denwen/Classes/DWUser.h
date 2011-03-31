//
//  DWUser.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "DWPoolObject.h"
#import "UIImage+ImageProcessing.h"

#import "NSString+Helpers.h"
#import "DWConstants.h"



@interface DWUser : DWPoolObject {
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
	BOOL _hasPhoto;
	BOOL _isProcessed;
}


//Initialization

//Update 
- (void)updatePreviewURLs:(NSDictionary*)place;
- (void)updatePreviewImages:(UIImage*)image;

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

- (BOOL)isCurrentUser;


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


@property (readonly) BOOL hasPhoto;

@end

