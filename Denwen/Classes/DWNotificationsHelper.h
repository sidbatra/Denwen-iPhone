//
//  DWNotificationsHelper.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Handle the notifications flow of the app
 */
@interface DWNotificationsHelper : NSObject {
	NSInteger _unreadItems;
}

/**
 * The sole shared instance of the class
 */
+ (DWNotificationsHelper *)sharedDWNotificationsHelper;

/**
 * Total unread items on the feed page
 */
@property (nonatomic,assign) NSInteger unreadItems;

/**
 * Handle push notifications when the app is open
 */
- (void)handleLiveNotificationWithUserInfo:(NSDictionary*)userInfo;

/**
 * Handle push notifications when the app is in the background
 */
- (void)handleBackgroundNotification;

/**
 * Reset the application badege number and sent the read count to the
 * server
 */
- (void)resetUnreadCount;

@end
