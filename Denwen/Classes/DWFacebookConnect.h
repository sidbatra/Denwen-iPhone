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
 * Facebook iOS SDK object
 */
@property (nonatomic,retain) Facebook *facebook;

/**
 * DWFacebookConnectDelegate
 */
@property (nonatomic,assign) id<DWFacebookConnectDelegate> delegate;

@end


/**
 * Protocol to fire events about the fbSharing lifecycle
 */
@protocol DWFacebookConnectDelegate 
- (void)fbSharingDone;
- (void)fbSharingCancelled;
@end