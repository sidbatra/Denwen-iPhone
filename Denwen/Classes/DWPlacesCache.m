//
//  DWPlacesCache.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlacesCache.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"
#import "DWSession.h"

#import "SynthesizeSingleton.h"

static NSInteger const kCapacity		= 1;
static NSInteger const kNearbyIndex		= 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlacesCache

@synthesize placesManager		= _placesManager;
@synthesize nearbyPlacesReady	= _nearbyPlacesReady;

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
- (NSMutableArray*)getNearbyPlaces {
	return [self.placesManager getPlacesAtRow:kNearbyIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)loadNearbyPlaces {
	[[DWRequestsManager sharedDWRequestsManager] getNearbyPlaces];
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
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNNearbyPlacesCacheUpdated
															object:nil];
	}
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

@end
