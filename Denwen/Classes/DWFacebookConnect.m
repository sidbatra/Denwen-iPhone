//
//  DWFacebookConnect.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFacebookConnect.h"
#import "DWRequestsManager.h"
#import "DWSession.h"
#import "DWConstants.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFacebookConnect

@synthesize facebook    = _facebook;
@synthesize delegate    = _delegate;

//----------------------------------------------------------------------------------------------------
- (id)init {
    
    self = [super init];
    
    if(self) {
        self.facebook	= [[[Facebook alloc] initWithAppId:kFacebookAppID] autorelease];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(facebookURLOpened:) 
													 name:kNFacebookURLOpened
												   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.facebook   = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)authenticate {
    
    if([DWSession sharedDWSession].currentUser.facebookAccessToken) {
		self.facebook.accessToken		= [DWSession sharedDWSession].currentUser.facebookAccessToken;
		self.facebook.expirationDate	= [NSDate distantFuture];
        
        [_delegate fbAuthenticated];
	}
    else {
        [self.facebook authorize:[NSArray arrayWithObjects:
                                  @"offline_access", 
                                  @"publish_stream",
                                  @"user_checkins",
                                  @"user_hometown",
                                  @"user_likes",
                                  @"user_location",
                                  @"user_work_history",
                                  @"friends_work_history",
                                  @"friends_checkins",
                                  @"user_events",nil] 
                        delegate:self];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)createWallPostWithMessage:(NSString*)message 
                             name:(NSString*)name 
                      description:(NSString*)description 
                          caption:(NSString*)caption
                             link:(NSString*)link
                       pictureURL:(NSString*)pictureURL {
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   message				,@"message",
                                   name                 ,@"name",
                                   description			,@"description",
                                   caption              ,@"caption",
                                   link                 ,@"link",
                                   pictureURL			,@"picture",
                                   nil];
    
    [self.facebook requestWithGraphPath:@"/me/feed"   
							  andParams:params
						  andHttpMethod:@"POST"
							andDelegate:self];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)facebookURLOpened:(NSNotification*)notification {
	[self.facebook handleOpenURL:(NSURL*)[notification object]];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark FBSessionDelegate

//----------------------------------------------------------------------------------------------------
- (void)fbDidLogin {
	[[DWSession sharedDWSession].currentUser storeFacebookToken:self.facebook.accessToken];
	[[DWRequestsManager sharedDWRequestsManager] updateFacebookTokenForCurrentUser:self.facebook.accessToken];
    
    [_delegate fbAuthenticated];
}

//----------------------------------------------------------------------------------------------------
-(void)fbDidNotLogin:(BOOL)cancelled {
    [_delegate fbAuthenticationFailed];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark FBReqestDelegate

//----------------------------------------------------------------------------------------------------
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	/**
	 * Called when the Facebook API request has returned a response. This callback
	 * gives you access to the raw response. It's called before
	 * (void)request:(FBRequest *)request didLoad:(id)result,
	 * which is passed the parsed response object.
	 */
}

//----------------------------------------------------------------------------------------------------
- (void)request:(FBRequest *)request didLoad:(id)result {
	/** 
	 * Called when a request returns and its response has been parsed into
	 * an object. The resulting object may be a dictionary, an array, a string,
	 * or a number, depending on the format of the API response. If you need access
	 * to the raw response, use:
	 *
	 * (void)request:(FBRequest *)request
	 *      didReceiveResponse:(NSURLResponse *)response
	 */
	
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
    
    [_delegate fbSharingDone];
}


//----------------------------------------------------------------------------------------------------
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [_delegate fbSharingFailed];
}



@end
