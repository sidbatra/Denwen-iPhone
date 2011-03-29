//
//  DWNearbyPlacesViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWNearbyPlacesViewController.h"

//Declarations for private methods
//
@interface DWNearbyPlacesViewController () 
@end


@implementation DWNearbyPlacesViewController


#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super initWithNibName:@"DWPlaceListViewController" bundle:nil searchType:YES withCapacity:1 andDelegate:delegate];
	
	if (self) {		
		[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(newPlaceCreated:) 
												 name:N_NEW_PLACE_CREATED 
											   object:nil];
		
		if (&UIApplicationWillEnterForegroundNotification != NULL) {
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationEnteringForeground:) 
														 name:UIApplicationWillEnterForegroundNotification
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

		
	}
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGRect frame = self.view.frame;
	frame.origin.y = SEGMENTED_VIEW_HEIGHT; 
	frame.size.height = frame.size.height - SEGMENTED_VIEW_HEIGHT;
	self.view.frame = frame;
	
	self.view.hidden = YES;
	
	self.searchDisplayController.searchBar.placeholder = @"Search Nearby Places";
}



#pragma mark -
#pragma mark Notification handlers



// Fired when the user creates a new place
//
- (void)newPlaceCreated:(NSNotification*)notification {
	DWPlace *place = (DWPlace*)[notification object];
	
	if(_isLoadedOnce && [[DWSession sharedDWSession].location distanceFromLocation:place.location] <= LOCATION_NEARBY_RADIUS)	
		[self addNewPlace:place];
}


// Fired when the app is about to enter the foreground
//
- (void)applicationEnteringForeground:(NSNotification*)notification {
	if(_isLoadedOnce)
		[self hardRefresh];
}



#pragma mark -
#pragma mark Methods to obtain places from the server


// Send a request to load popoular places
//
- (void)loadPlaces {
	[super loadPlaces];
	
	[[DWRequestsManager sharedDWRequestsManager] getNearbyPlaces];
}



#pragma mark -
#pragma mark RequestManager Delegate methods


- (void)nearbyPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		[_placeManager populatePlaces:places atIndex:0];
		
		
		if([_placeManager totalPlacesAtRow:0]) 
			_tableViewUsage = TABLE_VIEW_AS_DATA;
		else {
			self.messageCellText = NO_PLACES_NEARBY_MSG;
			_tableViewUsage = TABLE_VIEW_AS_MESSAGE;
		}
		
		_isLoadedOnce = YES;
		
		[self markEndOfPagination];
		[self.tableView reloadData];
	}	
	
	[self finishedLoadingPlaces];
}


- (void)nearbyPlacesError:(NSNotification*)notification {
	[self finishedLoadingPlaces];
}



#pragma mark -
#pragma mark Memory management

// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}


// The usual memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end

