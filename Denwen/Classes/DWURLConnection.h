//
//  DWURLConnection.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWCache.h"


@protocol DWURLConnectionDelegate;


@interface DWURLConnection : NSObject {
	id <DWURLConnectionDelegate> _delegate;
	
	NSURLConnection *_connection;
	NSMutableData *_data;
	NSString *_key;
	
	NSInteger _instanceID;
	
	BOOL _shouldCache;
	BOOL _shouldActivitySpin;
	BOOL _isFinished;
}


- (id)initWithDelegate:(id)delegate;
- (id)initWithDelegate:(id)delegate withInstanceID:(NSInteger)instanceID;

- (void)fetchData:(NSString*)urlString withKey:(NSString*)theKey withCache:(BOOL)cache;
- (void)fetchData:(NSString*)urlString withKey:(NSString*)theKey withCache:(BOOL)cache withActivitySpinner:(BOOL)activitySpinner;

//- (void)sendData:(NSString *)urlString withPostString:(NSString*)postString;
- (void)sendDataAsynchronously:(NSString*)urlString withPostString:(NSString*)postString;
- (void)sendDataAsynchronously:(NSString*)urlString withPostString:(NSString*)postString 
			   withRequestType:(NSString*)requestType;

- (void)cancel;

@end


@protocol DWURLConnectionDelegate
- (void)finishedLoadingData:(NSMutableData*)data forInstanceID:(NSInteger)instanceID;
- (void)errorLoadingData:(NSError*)error forInstanceID:(NSInteger)instanceID;
@end

