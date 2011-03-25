//
//  DWRequest.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#import "DWRequest.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWRequest

@synthesize successNotification		= _successNotification;
@synthesize errorNotification		= _errorNotification;


//----------------------------------------------------------------------------------------------------
- (id)initWithRequestURL:(NSString*)requestURL 
	 successNotification:(NSString*)theSuccessNotification
	   errorNotification:(NSString*)theErrorNotification {
	
	NSURL *tempURL = [NSURL URLWithString:requestURL];
	
	self = [super initWithURL:tempURL];
	
	if(self != nil) {
		self.successNotification	= theSuccessNotification;
		self.errorNotification		= theErrorNotification;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.successNotification	= nil;
	self.errorNotification		= nil;
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Stubs

//----------------------------------------------------------------------------------------------------
- (void)processResponse:(NSString*)responseString andResponseData:(NSData*)responseData {}

//----------------------------------------------------------------------------------------------------
- (void)processError:(NSError*)error {}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Static

//----------------------------------------------------------------------------------------------------
+ (id)requestWithRequestURL:(NSString*)requestURL
		successNotification:(NSString*)theSuccessNotification
		  errorNotification:(NSString*)theErrorNotification {
	
	return [[[self alloc] initWithRequestURL:requestURL
						 successNotification:theSuccessNotification
						   errorNotification:theErrorNotification
			 ] 
			autorelease];
}


@end
