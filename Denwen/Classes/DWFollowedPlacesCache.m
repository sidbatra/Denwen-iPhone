//
//  DWFollowedPlacesCache.m
//  Denwen
//
//  Created by Siddharth Batra on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWFollowedPlacesCache.h"


@implementation DWFollowedPlacesCache

@synthesize places=_places,requestManager=_requestManager;


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
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeFollowed:) 
													 name:N_PLACE_FOLLOWED
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placeUnfollowed:) 
													 name:N_PLACE_UNFOLLOWED
												   object:nil];
	}
	
	return self;  
}



// Fetch followed places for the current user to start the cache
//
- (void)loadPlaces {
	return;
	
	DWRequestManager *tempRequestManager = [[DWRequestManager alloc] initWithDelegate:self];
	self.requestManager = tempRequestManager;
	[tempRequestManager release];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?email=%@&password=%@&ff=mobile",
						   FOLLOWED_PLACES_URI,
						   [DWSession sharedDWSession].currentUser.email,
						   [DWSession sharedDWSession].currentUser.encryptedPassword
						   ];
	[self.requestManager sendGetRequest:urlString];
	
	[urlString release];
}


// Populate the mutable places array from the given 
// immutable array
//
- (void)populatePlaces:(NSArray*)newPlaces {
	if(!_places)
		_places = [[NSMutableArray alloc] init];
	
	[_places removeAllObjects];
	
	for(NSDictionary *place in newPlaces)
		[_places addObject:place];
}


// Generates an immutable places array 
//
- (NSArray*)generateImmutablePlaces {
	return [NSArray arrayWithArray:_places];
}



#pragma mark -
#pragma mark Notification handlers


// Fired when the app is about to enter the foreground
//
- (void)applicationBecomesActive:(NSNotification*)notification {
	if([[DWSession sharedDWSession] isActive])
		[self loadPlaces];
}


// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
	[self loadPlaces];
}	


// Maintain places array when a place is followed
//
- (void)placeFollowed:(NSNotification*)notification {
	NSDictionary *placeJSON = (NSDictionary*)[notification object];
	[_places insertObject:placeJSON atIndex:0];
}


// Maintain places array when a place is unfollowed
//
- (void)placeUnfollowed:(NSNotification*)notification {
	NSDictionary *placeJSON = (NSDictionary*)[notification object];
	NSInteger newPlaceID = [[placeJSON objectForKey:@"id"] integerValue];
	
	for(int i=0; i<[_places count];i++) {
		if([[[_places objectAtIndex:i] objectForKey:@"id"] integerValue] == newPlaceID) {
			[_places removeObjectAtIndex:i];
			break;
		}
	}
}



#pragma mark -
#pragma mark RequestManager

// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		[self populatePlaces:[body objectForKey:PLACES_JSON_KEY]];
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
	self.requestManager = nil;
	[_places release];
    [super dealloc];
}


@end
