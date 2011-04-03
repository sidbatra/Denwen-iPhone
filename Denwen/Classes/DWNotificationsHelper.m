//
//  DWNotificationsHelper.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNotificationsHelper.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

#import "SynthesizeSingleton.h"


static NSString* const kKeyAPS		= @"aps";
static NSString* const kKeyBadge	= @"badge";
static NSString* const kKeyAlert	= @"alert";
static NSString* const kAlertTitle	= @"Denwen";
static NSString* const kCancelTitle	= @"OK";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNotificationsHelper

@synthesize unreadItems = _unreadItems;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWNotificationsHelper);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)handleLiveNotificationWithUserInfo:(NSDictionary*)userInfo {
	
	NSDictionary *aps		= (NSDictionary*)[userInfo objectForKey:kKeyAPS];
	NSString *badgeString	= [aps objectForKey:kKeyBadge];
	NSString *alertString	= [aps objectForKey:kKeyAlert];
	
	if(badgeString) {
		self.unreadItems = [badgeString integerValue];
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.unreadItems];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:kPNLive],kKeyNotificationType,
									nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNNewApplicationBadge 
															object:nil
														  userInfo:userInfo];
	}
	
	if(alertString && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitle
														 message:alertString 
														delegate:nil 
											   cancelButtonTitle:kCancelTitle
											   otherButtonTitles: nil];
		 [alert show];
		 [alert release];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)handleBackgroundNotification {
	self.unreadItems = [UIApplication sharedApplication].applicationIconBadgeNumber;
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:kPNBackground],kKeyNotificationType,
							  nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNNewApplicationBadge 
														object:nil
													  userInfo:userInfo];
}

//----------------------------------------------------------------------------------------------------
- (void)resetUnreadCount {
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	if(self.unreadItems)
		[[DWRequestsManager sharedDWRequestsManager] updateUnreadCountForCurrentUserBy:self.unreadItems];
	
	self.unreadItems = 0;
}

@end
