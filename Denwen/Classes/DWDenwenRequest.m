//
//  DWDenwenRequest.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#import "DWDenwenRequest.h"



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
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:theError,kKeyError,nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:self.errorNotification
														object:nil
													  userInfo:info];
}



@end
