//
//  DWDenwenRequest.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#import "DWDenwenRequest.h"

#import "JSON.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWDenwenRequest


//----------------------------------------------------------------------------------------------------
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData {
	/**
	 * Parse fixed fields in the Denwen response and package them into a notification object
	 */
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:self.resourceID]				,kKeyResourceID,
									[[responseString JSONValue] objectForKey:kKeyStatus]	,kKeyStatus,
									[[responseString JSONValue] objectForKey:kKeyBody]		,kKeyBody,
									[[responseString JSONValue] objectForKey:kKeyMessage]	,kKeyMessage,
									nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:self.successNotification 
														object:nil
													  userInfo:info];
}

//----------------------------------------------------------------------------------------------------
- (void)processError:(NSError*)theError {
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:self.resourceID]	,kKeyResourceID,
								theError									,kKeyError,
								nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:self.errorNotification
														object:nil
													  userInfo:info];
}



@end
