//
//  DWPlacesCache.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlacesCache.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"
#import "DWSession.h"

#import "SynthesizeSingleton.h"

static NSInteger const kCapacity		= 2;
static NSInteger const kNearbyIndex		= 0;
static NSInteger const kFollowedIndex	= 1;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlacesCache

@synthesize placesManager			= _placesManager;
@synthesize nearbyPlacesReady		= _nearbyPlacesReady;
@synthesize followedPlacesReady		= _followedPlacesReady;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWPlacesCache);

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
		self.placesManager = [[[DWPlacesManager alloc] initWithCapacity:kCapacity] autorelease];
		
		_refreshNearbyPlacesOnNextLocationUpdate = YES;
		
		if (&UIApplicationDidEnterBackgroundNotification != NULL) {
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationEnteringBackground:) 
														 name:UIApplicationDidEnterBackgroundNotification
													   object:nil];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationDidBecomeActive:) 
													 name:UIApplicationDidBecomeActiveNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:kNUserLogsIn
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(nearbyPlacesLoaded:) 
													 name:kNNearbyPlacesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(nearbyPlacesError:) 
													 name:kNNearbyPlacesError
												   object:nil];	
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newPlaceParsed:) 
													 name:kNNewPlaceParsed 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newLocationAvailable:) 
													 name:kNNewLocationAvailable 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPlacesLoaded:) 
													 name:kNUserPlacesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPlacesError:) 
													 name:kNUserPlacesError
												   object:nil];
		
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.placesManager = nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isFollowedPlace:(DWPlace*)thePlace {
	
	BOOL status = NO;
	
	NSMutableArray *followedPlaces = [self getFollowedPlaces];
	
	for(DWPlace *place in followedPlaces) {
		if(place.databaseID == thePlace.databaseID) {
			status = YES;
			break;
		}
	}
	
	return status;
}

//----------------------------------------------------------------------------------------------------
- (NSMutableArray*)getNearbyPlaces {
	return [self.placesManager getPlacesAtRow:kNearbyIndex];
}

//----------------------------------------------------------------------------------------------------
- (NSMutableArray*)getFollowedPlaces {
	return [self.placesManager getPlacesAtRow:kFollowedIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)loadNearbyPlaces {
	[[DWRequestsManager sharedDWRequestsManager] getNearbyPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)loadFollowedPlaces {
	if([[DWSession sharedDWSession] isActive])
		[[DWRequestsManager sharedDWRequestsManager] getUserPlaces:[DWSession sharedDWSession].currentUser.databaseID];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)applicationEnteringBackground:(NSNotification*)notification {
	_refreshNearbyPlacesOnNextLocationUpdate = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)newPlaceParsed:(NSNotification*)notification {
	DWPlace *place = (DWPlace*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyPlace];
	
	if([[DWSession sharedDWSession].location distanceFromLocation:place.location] <= kLocNearbyRadius)	{
		
		[self.placesManager addPlace:place 
							   atRow:kNearbyIndex
						   andColumn:0];
	}
	
	[self.placesManager addPlace:place 
						   atRow:kFollowedIndex
					   andColumn:0];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNNearbyPlacesCacheUpdated
														object:nil];	
}

//----------------------------------------------------------------------------------------------------
- (void)nearbyPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
				
		[self.placesManager populatePlaces:[[info objectForKey:kKeyBody] objectForKey:kKeyPlaces]
								   atIndex:kNearbyIndex];
		
		_nearbyPlacesReady = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNNearbyPlacesCacheUpdated
															object:nil];
	}	
}

//----------------------------------------------------------------------------------------------------
- (void)nearbyPlacesError:(NSNotification*)notification {
}

//----------------------------------------------------------------------------------------------------
- (void)newLocationAvailable:(NSNotification*)notification {
	if(_refreshNearbyPlacesOnNextLocationUpdate) {
		[self loadNearbyPlaces]; 
		_refreshNearbyPlacesOnNextLocationUpdate = NO;
	}
}

//----------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(NSNotification*)notification {
	if(!_followedPlacesReady) {
		[self loadFollowedPlaces];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)userLogsIn:(NSNotification*)notification {
	[self loadFollowedPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)userPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != [DWSession sharedDWSession].currentUser.databaseID)
		return;
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		[self.placesManager populatePlaces:[[info objectForKey:kKeyBody] objectForKey:kKeyPlaces]
							  atIndex:kFollowedIndex];
		
		_followedPlacesReady = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNFollowedPlacesCacheUpdated
															object:nil];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)userPlacesError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != [DWSession sharedDWSession].currentUser.databaseID)
		return;
}

@end
