//
//  DWRequestManager.h
//  Denwen
//
//  Created by Siddharth Batra on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWURLConnection.h"
#import "JSON.h"



@protocol DWRequestManagerDelegate;


@interface DWRequestManager : NSObject<DWURLConnectionDelegate> {
	id <DWRequestManagerDelegate> _delegate;
	
	DWURLConnection *_connection;
	
	int _instanceID;
}

- (id)initWithDelegate:(id)delegate;
- (id)initWithDelegate:(id)delegate andInstanceID:(int)instanceID;

- (void)sendGetRequest:(NSString*)urlString;
- (void)sendPostRequest:(NSString*)url withParams:(NSString*)params;
- (void)sendPutRequest:(NSString*)url withParams:(NSString*)params;
- (void)sendDeleteRequest:(NSString*)url withParams:(NSString*)params;

@end

@protocol DWRequestManagerDelegate
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID;
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID;
@end