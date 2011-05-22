//
//  DWTwitterConnect.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TwitterAuthenticator.h"
#import "TwitterTweetPoster.h"

@class TwitterConsumer;
@protocol DWTwitterConnectDelegate;

/**
 * Wrapper over the Twitter XAuth Libs
 */
@interface DWTwitterConnect : NSObject<TwitterAuthenticatorDelegate,TwitterTweetPosterDelegate> {
    TwitterConsumer         *_consumer;
    TwitterAuthenticator    *_authenticator;
    TwitterTweetPoster      *_poster;
    
    id<DWTwitterConnectDelegate>    _delegate;
}

/**
 * Represents the API client
 */
@property (nonatomic,retain) TwitterConsumer *consumer;

/**
 * Performs authentications of behalf of the user
 */
@property (nonatomic,retain) TwitterAuthenticator *authenticator;

/**
 * Tweet posting wrapper
 */
@property (nonatomic,retain) TwitterTweetPoster *poster;

/**
 * DWTwitterConnectDelegate
 */
@property (nonatomic,assign) id<DWTwitterConnectDelegate> delegate;


/**
 * Obtain token and secret for disptaching tweets
 */
- (void)authenticate;

/**
 * Send tweet on behalf of the user
 */
- (void)createTweetWithText:(NSString*)text;

@end


/**
 * Delegate protocol to fire events about the Twitter authentication
 * and sharing lifecycle
 */
@protocol DWTwitterConnectDelegate
- (void)twAuthenticated;
- (void)twAuthenticating;
- (void)twAuthenticationFailed;
- (void)twSharingDone;
- (void)twSharingFailed;
@end
