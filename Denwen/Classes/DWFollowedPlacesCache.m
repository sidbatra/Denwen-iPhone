//
//  DWFollowedPlacesCache.m
//  Denwen
//
//  Created by Siddharth Batra on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWFollowedPlacesCache.h"


@implementation DWFollowedPlacesCache

@synthesize places=_places;


SYNTHESIZE_SINGLETON_FOR_CLASS(DWFollowedPlacesCache);


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {		
		_places = nil;
		_retries = 0;
		_requestManager = nil;
		
		if (&UIApplicationDidBecomeActiveNotification != NULL) {
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationBecomesActive:) 
														 name:UIApplicationDidBecomeActiveNotification
													   object:nil];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
												   object:nil];
	}
	
	return self;  
}



// Fetch followed places for the current user to start the cache
//
- (void)loadPlaces {
	[_requestManager release];
	_requestManager = nil;
	_requestManager = [[DWRequestManager alloc] initWithDelegate:self];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?email=%@&password=%@&ff=mobile",
						   FOLLOWED_PLACES_URI,
						   currentUser.email,
						   currentUser.encryptedPassword
						   ];
	[_requestManager sendGetRequest:urlString];
	
	[urlString release];
}





#pragma mark -
#pragma mark Notification handlers


// Fired when the app is about to enter the foreground
//
- (void)applicationBecomesActive:(NSNotification*)notification {
	if([DWSessionManager isSessionActive])
		[self loadPlaces];
}


// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
	[self loadPlaces];
}	



#pragma mark -
#pragma mark RequestManager

// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		self.places = [body objectForKey:PLACES_JSON_KEY];
		_retries = 0;
	}
	else {
		
	}
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	if(++_retries < 3)
		[self loadPlaces];
}



#pragma mark -
#pragma mark Memory Management

// The usual dealloc
//
- (void)dealloc {
	[_requestManager release];
    [super dealloc];
}


@end
