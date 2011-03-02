//
//  DWRequestManager.m
//  Denwen
//
//  Created by Siddharth Batra on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWRequestManager.h"

@interface DWRequestManager() 
- (void)cancel;
@end

@implementation DWRequestManager


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate {
	return [self initWithDelegate:delegate andInstanceID:0];
}

	 
// Init the class and set the delegate member variable and an instanceID which
// is useful for disambugating multiple instances of RequestManager in the same class
//
- (id)initWithDelegate:(id)delegate andInstanceID:(int)instanceID {
	self = [super init];
	
	if(self != nil) {
		_delegate = delegate;
		_instanceID = instanceID;
	}
	
	return self;
}



#pragma mark -
#pragma mark Requst launching methods


// Send a get request to the given urlString
//
- (void)sendGetRequest:(NSString*)urlString {
	
	[self cancel];		
	
	_connection = [[DWURLConnection alloc] initWithDelegate:self];
	[_connection fetchData:urlString withKey:nil withCache:NO withActivitySpinner:YES];
}


// Send a post request to the given url 
//
- (void)sendPostRequest:(NSString*)url withParams:(NSString*)params {
	
	[self cancel];
	
	_connection = [[DWURLConnection alloc] initWithDelegate:self];
	[_connection sendDataAsynchronously:url withPostString:params];
}


// Send a put request to the given url 
//
- (void)sendPutRequest:(NSString*)url withParams:(NSString*)params {
	
	[self cancel];
	
	_connection = [[DWURLConnection alloc] initWithDelegate:self];
	[_connection sendDataAsynchronously:url withPostString:params withRequestType:PUT_STRING];
}




// Send a delete request to the given url 
//
- (void)sendDeleteRequest:(NSString*)url withParams:(NSString*)params {
	
	[self cancel];
	
	_connection = [[DWURLConnection alloc] initWithDelegate:self];
	[_connection sendDataAsynchronously:url withPostString:params withRequestType:DELETE_STRING];
}


#pragma mark -
#pragma mark GURLConnection delegate


// Send an errorLoadingItems message to the delegate when the connection to the
// server fails
//
- (void)errorLoadingData:(NSError *)error forInstanceID:(NSInteger)instanceID {
	[_connection release];
    _connection = nil;
	
	[_delegate errorWithRequest:error forInstanceID:_instanceID];
}


// Upon a successful connection, the response status,body & message from the downloaded
// JSON string and pass them along to the delegate
//
- (void)finishedLoadingData:(NSMutableData *)data forInstanceID:(NSInteger)instanceID {
	NSString *jsonString = [[NSString alloc] initWithBytes:[data bytes] 
													length:[data length] 
												  encoding:NSUTF8StringEncoding];
	
	NSString *status = [[jsonString JSONValue] objectForKey:@"status"];
	NSDictionary *body = [[jsonString JSONValue] objectForKey:@"body"];
	NSString *message = [[jsonString JSONValue] objectForKey:@"message"];
	
	[_delegate didFinishRequest:status withBody:body withMessage:message withInstanceID:_instanceID];
	
	[_connection release];
	_connection = nil;
	[jsonString release];
}



#pragma mark -
#pragma mark Memory management

//Cancel any existing open connections
//
- (void)cancel {
	if(_connection) {
		[_connection cancel];
		[_connection release];
		_connection = nil;
	}
}


// The usual cleanup
//
- (void)dealloc {
	
	[self cancel];
	
	_delegate = nil;
	
	[super dealloc];
}


@end
