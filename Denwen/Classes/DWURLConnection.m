//
//  DWURLConnection.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "DWURLConnection.h"


@implementation DWURLConnection


// Init with the default instanceID
//
- (id)initWithDelegate:(id)delegate {
	return [self initWithDelegate:delegate withInstanceID:0];
}


// Init an instance of the class with the delegate along with an instance ID
//
- (id)initWithDelegate:(id)delegate withInstanceID:(NSInteger)instanceID {
	self = [super init];
	
	if(self != nil) {
		_connection = nil;
		_data = nil;
		_key = nil;
		_isFinished = NO;
		
		_delegate = delegate;
		_instanceID = instanceID;
	}
	
	return self;
}


// Calls the main overloaded fetchData method with activitySpinner set to NO
//
-(void) fetchData:(NSString *)urlString withKey:(NSString*)theKey withCache:(BOOL)cache{
	[self fetchData:urlString withKey:theKey withCache:cache withActivitySpinner:NO];
}


// Launches a download in a new thread. theKey is used to uniquely identify a cache entry
// and the withCache flag signifies whether caching should be used or not. the activitySpinner
// flag indicates whether the iPhone activity indicator should be turned on during the download
//
-(void) fetchData:(NSString *)urlString withKey:(NSString*)theKey withCache:(BOOL)cache 
		withActivitySpinner:(BOOL)activitySpinner {
	
	NSMutableData *cachedData = nil;
	_shouldCache = cache;
	_shouldActivitySpin = activitySpinner;
	_isFinished = NO;
	
	//Test the cache for the given _key only if its a valid cache _key
	if(_shouldCache) {
		
		if(_key) {
			[_key release];
			_key = nil;
		}	
		
		_key = [[NSString alloc] initWithString:theKey];
		cachedData = [DWCache fetchDataForKey:_key];
	}
	
	//If found immediately call the _delegate avoiding all downloading cost
	//
	if (cachedData) {
		[_delegate finishedLoadingData:cachedData forInstanceID:_instanceID];
	}
	else {
		if (_shouldActivitySpin)
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
		
		_connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
		
		[urlRequest release];
		[url release];
	}
}



// Sends a synchronus post request to the given url with the given parameters
//
/*-(void)sendData:(NSString *)urlString withPostString:(NSString*)postString {
	
	_shouldCache = NO;
	_shouldActivitySpin = YES;
	_isFinished = NO;
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	//Construct the URL request with the post _data
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	[urlRequest setHTTPMethod:@POST_STRING];
	[urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSError *errorResponse = nil;
	NSURLResponse *response = nil;	
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest 
												 returningResponse:&response
															 error:&errorResponse];
	NSMutableData *returnData = [[NSMutableData alloc] init];
	[returnData appendData:responseData];
	
	
	if(errorResponse)
		[_delegate errorLoadingData:errorResponse forInstanceID:_instanceID];
	else
		[_delegate finishedLoadingData:[returnData autorelease] forInstanceID:_instanceID];
	
	_isFinished = YES;
	[urlRequest release];
	[url release];	
}*/


// Sends an asynchronous post request to the given url with the given parameters
//
- (void)sendDataAsynchronously:(NSString*)urlString withPostString:(NSString*)postString {
	[self sendDataAsynchronously:urlString withPostString:postString withRequestType:POST_STRING];
}


// Sends an asynchronous request to the given url with the given parameters and request type
//
- (void)sendDataAsynchronously:(NSString*)urlString withPostString:(NSString*)postString 
			   withRequestType:(NSString*)requestType {
	
	_shouldCache = NO;
	_shouldActivitySpin = YES;
	_isFinished = NO;
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	//Construct the URL request with the post _data
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	[urlRequest setHTTPMethod:requestType];
	
	if([requestType isEqualToString:POST_STRING])
		[urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	
	_connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	
	[urlRequest release];
	[url release];	
}



#pragma mark -
#pragma mark NSURLConnection Message Receivers

// Initial response received from server
//
- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response {
	if(_data)
		[_data release];
	
	_data = [[NSMutableData alloc] init];
}


// Called upon incremental receipts of data
//
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    [_data appendData:incrementalData];
}


// When data finished loading, send it via a message to the delegate
//
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	[_connection release];
	_connection=nil;
	
	_isFinished = YES;

	if (_shouldCache)
		[DWCache setDataForKey:_key withData:_data];
	
	[_delegate finishedLoadingData:_data forInstanceID:_instanceID];
	
	if (_shouldActivitySpin)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}


// Format error and send it via a message to the delegate
//
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	
	if(_data) {
		[_data release];
		_data = nil;
	}
	
	[_connection release];
    _connection = nil;
	
	_isFinished = YES;
	
	if (_shouldActivitySpin)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[_delegate errorLoadingData:error forInstanceID:_instanceID];
}



#pragma mark -
#pragma mark Memory management


//Cancel any open _connection
//
-(void)cancel {
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
	
	if(_data)
		[_data release];
	
	if(_key)
		[_key release];
	
	_delegate = nil;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[super dealloc];
}

@end

