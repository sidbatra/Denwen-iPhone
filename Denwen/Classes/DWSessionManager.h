//
//  DWSessionManager.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWUser.h"

extern DWUser *currentUser;
extern BOOL currentUserFollowedItemsRefresh;
extern BOOL currentUserFollowedPlacesRefresh;


@interface DWSessionManager : NSObject {
	
}

+ (void)checkDiskForSession;
+ (void)createSessionWithUser:(DWUser*)newUser;
+ (void)destroyCurrentSession;

+ (BOOL)isSessionActive;

@end
