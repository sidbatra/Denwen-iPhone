//
//  DWTwitterConnect.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTwitterConnect.h"
#import "DWSession.h"
#import "DWRequestsManager.h"
#import "TwitterConsumer.h"
#import "TwitterToken.h"
#import "TwitterTweetPoster.h"
#import "DWConstants.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTwitterConnect

@synthesize consumer        = _consumer;
@synthesize authenticator   = _authenticator;
@synthesize poster          = _poster;
@synthesize delegate        = _delegate;

//----------------------------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    
    if(self) {
        self.consumer = [[[TwitterConsumer alloc] initWithKey:kTwitterOAuthConsumerKey 
                                                       secret:kTwitterOAuthConsumerSecret] autorelease];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.consumer       = nil;
    self.authenticator  = nil;
    self.poster         = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)authenticate {
    
    if([DWSession sharedDWSession].currentUser.twitterXAuthToken) {
        [_delegate twAuthenticated];
    }
    else {
        self.authenticator              = [TwitterAuthenticator new];

        self.authenticator.consumer     = self.consumer;
        self.authenticator.username     = @"qenwen";
        self.authenticator.password     = @"sometimes";
        self.authenticator.delegate     = self;

        [_authenticator authenticate];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)createTweetWithText:(NSString*)text {
    
    self.poster             = [TwitterTweetPoster new];
    
    self.poster.consumer    = self.consumer;
    self.poster.token       = (TwitterToken*)[NSKeyedUnarchiver unarchiveObjectWithData:[DWSession sharedDWSession].currentUser.twitterXAuthToken];
    self.poster.delegate    = self;
    self.poster.message     = text;
    
    [self.poster execute];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark TwitterAuthenticatorDelegate

//----------------------------------------------------------------------------------------------------
- (void) twitterAuthenticator:(TwitterAuthenticator*)twitterAuthenticator
             didFailWithError:(NSError*)error {
    
    [_delegate twAuthenticationFailed];
}

//----------------------------------------------------------------------------------------------------
- (void) twitterAuthenticator:(TwitterAuthenticator*)twitterAuthenticator
          didSucceedWithToken:(TwitterToken*)token {
    
    [[DWSession sharedDWSession].currentUser storeTwitterData:[NSKeyedArchiver archivedDataWithRootObject:token]];
    
    [[DWRequestsManager sharedDWRequestsManager] updateTwitterDataForCurrentUser:token.token
                                                                   twitterSecret:token.secret];
    
    [_delegate twAuthenticated];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark TwitterTweetPosterDelegate

//----------------------------------------------------------------------------------------------------
- (void)twitterTweetPosterDidSucceed:(TwitterTweetPoster*)twitterTweetPoster {
    [_delegate twSharingDone];
}

//----------------------------------------------------------------------------------------------------
- (void) twitterTweetPoster:(TwitterTweetPoster*)twitterTweetPoster 
           didFailWithError:(NSError*)error {
    
    [_delegate twSharingFailed];
}

@end
