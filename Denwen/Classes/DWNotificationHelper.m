//
//  DWNotificationHelper.m
//  Denwen
//
//  Created by Siddharth Batra on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWNotificationHelper.h"


NSInteger followedItemsUnreadCount = 0;


@implementation DWNotificationHelper


// Keep a copy of the number of unread items that have been read
// and fire a notification
//
+ (void)followedItemsRead {
	if(followedItemsUnreadCount) {
				
		NSString *unreadString = [NSString stringWithFormat:@"%d",followedItemsUnreadCount];
		followedItemsUnreadCount = 0;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:N_FOLLOWED_ITEMS_READ
															object:unreadString
		 ];
	}
}

@end
