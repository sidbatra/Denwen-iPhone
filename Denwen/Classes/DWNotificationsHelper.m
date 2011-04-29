//
//  DWNotificationsHelper.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNotificationsHelper.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

#import "SynthesizeSingleton.h"


static NSString* const kKeyAPS              = @"aps";
static NSString* const kKeyBadge            = @"badge";
static NSString* const kKeyAlert            = @"alert";
static NSString* const kAlertTitle          = @"Denwen";
static NSString* const kCancelTitle         = @"OK";
static NSString* const kActionTitle         = @"View";
static NSInteger const kActionButtonIndex   = 1;


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNotificationsHelper

@synthesize unreadItems             = _unreadItems;
@synthesize unreadNotifications     = _unreadNotifications;
@synthesize backgroundRemoteInfo    = _backgroundRemoteInfo;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWNotificationsHelper);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.backgroundRemoteInfo   = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)handleLiveNotificationWithUserInfo:(NSDictionary*)userInfo {
	
	NSDictionary *aps		= (NSDictionary*)[userInfo objectForKey:kKeyAPS];
	//NSString *badgeString	= [aps objectForKey:kKeyBadge];
	NSDictionary *alert     = [aps objectForKey:kKeyAlert];
    
	/*
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
	*/
    
    
	if(alert && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTitle
                                                             message:[alert objectForKey:kKeyBody] 
                                                            delegate:self 
                                                   cancelButtonTitle:kCancelTitle
                                                   otherButtonTitles:kActionTitle,nil];
		 [alertView show];
		 [alertView release];
	}
    else if(alert) {
        [self displayNotifications];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)handleBackgroundNotification {
    
    if(self.backgroundRemoteInfo) {
        [self displayNotifications];
        self.backgroundRemoteInfo = nil;
    }
	/*
    self.unreadItems = [UIApplication sharedApplication].applicationIconBadgeNumber;
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:kPNBackground],kKeyNotificationType,
							  nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNNewApplicationBadge 
														object:nil
													  userInfo:userInfo];
     */
}

//----------------------------------------------------------------------------------------------------
- (void)resetUnreadCount {
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	if(self.unreadItems)
		[[DWRequestsManager sharedDWRequestsManager] updateUnreadCountForCurrentUserBy:self.unreadItems];
	
	self.unreadItems = 0;
}

//----------------------------------------------------------------------------------------------------
- (void)displayNotifications {
    _unreadNotifications    = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNRequestTabBarIndexChange
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithInt:kTabBarFeedIndex],kKeyTabIndex,
                                                                [NSNumber numberWithBool:NO],kKeyPopAll,
                                                                nil]];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIAlertViewDelegate
//----------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	    
	if (buttonIndex == kActionButtonIndex)
        [self displayNotifications];
}

@end
