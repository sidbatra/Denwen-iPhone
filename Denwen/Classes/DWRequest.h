//
//  DWRequest.h
//  Copyright 2011 Denwen. All rights reserved.
//	

#import <Foundation/Foundation.h>

#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "JSON.h"
#import "Constants.h"

/**
 * Provides a base class for all requests
 */
@interface DWRequest : ASIFormDataRequest {
	NSString		*_successNotification;
	NSString		*_errorNotification;
}


/**
 * Name of the notification to be fired when the request finished 
 * successfully
 */
@property (nonatomic,copy) NSString *successNotification;

/**
 * Name of the notification to be fired when the request fails
 * with an error
 */
@property (nonatomic,copy) NSString *errorNotification;


/**
 * Init with request url and notification names to be invoked
 * after request execution
 */
- (id)initWithRequestURL:(NSString*)requestURL 
	 successNotification:(NSString*)theSuccessNotification
	   errorNotification:(NSString*)theErrorNotification;

/**
 * Static method to return an autoreleased object
 * created using initWithRequestURL
 */
+ (id)requestWithRequestURL:(NSString*)requestURL
		successNotification:(NSString*)theSuccessNotification
		  errorNotification:(NSString*)theErrorNotification;

/*
 * Stub method overriden by each child class to process the response
 * of a successful request
 */
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData;

/**
 * Stub method overriden by each child class to process an error
 * in finishing the request
 */
- (void)processError:(NSError*)error;


@end
