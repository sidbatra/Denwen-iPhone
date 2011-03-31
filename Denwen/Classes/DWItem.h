//
//  DWItem.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWMemoryPool.h"
#import "DWPoolObject.h"
#import "DWAttachment.h"
#import "DWPlace.h"
#import "DWUser.h"
#import "Constants.h"


@protocol DWItemDelegate;


@interface DWItem : DWPoolObject {
	NSTimeInterval _createdAtTimestamp;
	
	NSString *_data;
	NSArray *_urls;
	
	DWAttachment *_attachment;
	DWPlace *_place;
	DWUser *_user;
	
	BOOL _fromFollowedPlace; //Indicates whether the item belongs to a place that is 
							 //followed by the current user. Used when a new item is posted.
}


- (BOOL)hasAttachment;
- (NSString *)createdTimeAgoInWords;


//Functions for handling server interactions 
- (void)startRemoteImagesDownload;



@property (copy) NSString *data;
@property (copy) NSArray *urls;

@property (retain) DWAttachment *attachment;
@property (readonly) DWPlace *place;
@property (readonly) DWUser *user;

@property (assign) BOOL fromFollowedPlace;

@end

