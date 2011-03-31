//
//  DWNotificationHelper.h
//  Denwen
//
//  Created by Siddharth Batra on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWConstants.h"


extern NSInteger followedItemsUnreadCount;


@interface DWNotificationHelper : NSObject {

}

+ (void)followedItemsRead;

@end
