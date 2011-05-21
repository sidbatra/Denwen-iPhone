//
//  DWFacebookConnect.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBConnect.h"

@protocol DWFacebookConnectDelegate;

/**
 * Wrapper over the Facebook iOS SDK
 */
@interface DWFacebookConnect : NSObject<FBSessionDelegate,FBRequestDelegate> {
    Facebook    *_facebook;
    
    id<DWFacebookConnectDelegate> _delegate;
}

/**
 * Facebook iOS SDK interface instance
 */
@property (nonatomic,retain) Facebook *facebook;

/**
 * DWFacebookConnectDelegate
 */
@property (nonatomic,assign) id<DWFacebookConnectDelegate> delegate;


/**
 * If not authenticated ask for permissions, else setup auth token
 */
- (void)authenticate;

/**
 * Post a message to the wall
 */
- (void)createWallPostWithMessage:(NSString*)message 
                             name:(NSString*)name 
                      description:(NSString*)description 
                          caption:(NSString*)caption
                             link:(NSString*)link
                       pictureURL:(NSString*)pictureURL;

@end


/**
 * Protocol to fire events about the fbSharing lifecycle
 */
@protocol DWFacebookConnectDelegate 
- (void)fbAuthenticated;
- (void)fbAuthenticationFailed;
- (void)fbSharingDone;
- (void)fbSharingFailed;
@end