//
//  DWRequestsManager.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#import "DWRequestsManager.h"

static NSString* const kDenwenProtocol		= @"http://";

static NSString* const kPopularPlacesURI	= @"/popular/places.json";
static NSString* const kSearchPlacesURI		= @"/search/places.json";
static NSString* const kVisitsURI			= @"/visits.json";

static NSString* const kGet					= @"GET";
static NSString* const kPost				= @"POST";
static NSString* const kPut					= @"PUT";
static NSString* const kDelete				= @"DELETE";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWRequestsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DWRequestsManager);


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private

//----------------------------------------------------------------------------------------------------
- (NSString*)createDenwenRequestURL:(NSString*)localRequestURL {
	
	return	[NSString stringWithFormat:@"%@%@%@&email=%@&password=%@&ff=mobile",
				kDenwenProtocol,
				kDenwenServer,
				localRequestURL,
				[currentUser.email stringByEncodingHTMLCharacters],
				currentUser.encryptedPassword];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Requests

//----------------------------------------------------------------------------------------------------
- (void)requestPopularPlaces:(NSInteger)page {
	
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?page=%d",
									kPopularPlacesURI,
									page];
	
	NSString *requestURL = [self createDenwenRequestURL:localRequestURL];
	
	DWDenwenRequest *request = [DWDenwenRequest requestWithRequestURL:requestURL
												  successNotification:kNPopularPlacesLoaded
													errorNotification:kNPopularPlacesError];
	[request setDelegate:self];
	[request setRequestMethod:kGet];
	[request startAsynchronous];
}

//----------------------------------------------------------------------------------------------------
- (void)requestSearchPlaces:(NSString*)query {
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?q=%@",
								 kSearchPlacesURI,
								 [query stringByEncodingHTMLCharacters]
								 ];
	
	NSString *requestURL = [self createDenwenRequestURL:localRequestURL];
	
	DWDenwenRequest *request = [DWDenwenRequest requestWithRequestURL:requestURL
												  successNotification:kNSearchPlacesLoaded
													errorNotification:kNSearchPlacesError];
	[request setDelegate:self];
	[request setRequestMethod:kGet];
	[request startAsynchronous];	
}

//----------------------------------------------------------------------------------------------------
- (void)requestNewVisit {
	
	NSString *localRequestURL = [NSString stringWithFormat:@"%@?lat=%f&lon=%f",
									kVisitsURI,
									currentUserLocation.coordinate.latitude,
									currentUserLocation.coordinate.longitude];
	
	NSString *requestURL = [self createDenwenRequestURL:localRequestURL];
	
	DWDenwenRequest *request = [DWDenwenRequest requestWithRequestURL:requestURL
												  successNotification:nil
													errorNotification:nil];
	[request setDelegate:self];
	[request setRequestMethod:kPost];
	[request startAsynchronous];
}

//----------------------------------------------------------------------------------------------------
- (void)requestImageAt:(NSString*)url 
				ofType:(NSInteger)imageType 
			   ownedBy:(NSInteger)ownerID {
	
	DWImageRequest *request = [DWImageRequest requestWithRequestURL:url 
															ownerID:ownerID
														  imageType:imageType];
	[request setDelegate:self];
	[request setRequestMethod:kGet];
	[request startAsynchronous];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ASIHTTPRequestDelegate

//----------------------------------------------------------------------------------------------------
- (void)requestFinished:(DWRequest *)request {
	[request processResponse:[request responseString] andResponseData:[request responseData]];
}

//----------------------------------------------------------------------------------------------------
- (void)requestFailed:(DWRequest *)request {
	[request processError:[request error]];
}



@end
