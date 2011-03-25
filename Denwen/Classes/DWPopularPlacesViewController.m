//
//  DWPopularPlacesViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPopularPlacesViewController.h"


@implementation DWPopularPlacesViewController



// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super initWithNibName:@"DWPlaceListViewController" bundle:nil searchType:NO withCapacity:1 andDelegate:delegate];
	
	if (self) {
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
	
		
	self.searchDisplayController.searchBar.placeholder = @"Search All Places";
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(popularPlacesLoaded:) 
												 name:kNPopularPlacesLoaded
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(popularPlacesError:) 
												 name:kNPopularPlacesError
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(searchPlacesLoaded:) 
												 name:kNSearchPlacesLoaded
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(searchPlacesError:) 
												 name:kNSearchPlacesError
											   object:nil];
}



#pragma mark -
#pragma mark Notifications


- (void)popularPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:SUCCESS_STATUS]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:PLACES_JSON_KEY];
		[_placeManager populatePlaces:places atIndex:0 withClear:_reloading];						
		
		_tableViewUsage = TABLE_VIEW_AS_DATA;
	}

	
	[self finishedLoadingPlaces];
	[self.tableView reloadData];
}

- (void)popularPlacesError:(NSNotification*)notification {
	[self finishedLoadingPlaces];
	NSLog(@"ERROR - %@",[[notification userInfo] objectForKey:kKeyError]);	
}

- (void)searchPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];

	if([[info objectForKey:kKeyStatus] isEqualToString:SUCCESS_STATUS]) {
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:PLACES_JSON_KEY];
		[_placeManager populateFilteredPlaces:places];
		
		[self refreshFilteredPlacesUI];
	}
}

- (void)searchPlacesError:(NSNotification*)notification {
	[self finishedLoadingPlaces];
	NSLog(@"ERROR - %@",[[notification userInfo] objectForKey:kKeyError]);	
}

#pragma mark -
#pragma mark Methods to obtain places from the server


// Send a request to load popoular places
//
- (void)loadPlaces {
	[super loadPlaces];
	[[DWRequestsManager sharedDWRequestsManager] requestPopularPlaces:_currentPage];
}


// Send a request to search places based on the given query
//
- (void)searchPlaces:(NSString*)query {
	if(query.length >= 1)
		[[DWRequestsManager sharedDWRequestsManager] requestSearchPlaces:query];
}



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

