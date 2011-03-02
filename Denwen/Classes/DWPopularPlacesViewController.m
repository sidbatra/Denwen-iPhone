//
//  DWPopularPlacesViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPopularPlacesViewController.h"

//Declarations for private methods
//
@interface DWPopularPlacesViewController () 


@end


@implementation DWPopularPlacesViewController

#pragma mark -
#pragma mark View lifecycle


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
	
	self.view.hidden = YES;
	
	//if([DWSessionManager isSessionActive])
	//	[self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
	
	
	self.searchDisplayController.searchBar.placeholder = @"Search All Places";
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userLogsIn:) 
												 name:N_USER_LOGS_IN
											   object:nil];
}



#pragma mark -
#pragma mark Notification Observers

// Display search bar when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
	//[self.tableView setContentOffset:CGPointMake(0,0) animated:YES];
}



#pragma mark -
#pragma mark Methods to obtain places from the server


// Send a request to load popoular places
//
- (void)loadPlaces {
	[super loadPlaces];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?page=%d&ff=mobile",
						   POPULAR_PLACES_URI,
						   _currentPage
						   ];
	[_requestManager sendGetRequest:urlString];
	[urlString release];
}


// Send a request to search places based on the given query
//
- (void)searchPlaces:(NSString*)query {
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?q=%@&ff=mobile",
						   SEARCH_PLACES_URI,
						   [DWURLHelper encodeString:query]
						   ];
	[_searchRequestManager sendGetRequest:urlString];
	[urlString release];
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if(instanceID == 0 ) { // Parse and populate popular places
		
		if([status isEqualToString:SUCCESS_STATUS]) {
						
			NSArray *places = [body objectForKey:PLACES_JSON_KEY];
			[_placeManager populatePlaces:places atIndex:0 withClear:_reloading];						
			
			_tableViewUsage = TABLE_VIEW_AS_DATA;
		}
		else {
			
		}
		
		[self finishedLoadingPlaces];
		[self.tableView reloadData];
	}
	else if(instanceID == SEARCH_INSTANCE_ID) { // Parse and populate places search results for the given query
		
		if([status isEqualToString:SUCCESS_STATUS]) {
			NSArray *places = [body objectForKey:PLACES_JSON_KEY];
			[_placeManager populateFilteredPlaces:places];
			
			[self refreshFilteredPlacesUI];
		}
		else {
			
		}
	}
	
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	[self finishedLoadingPlaces];
}




#pragma mark -
#pragma mark Table view data source




#pragma mark -
#pragma mark Table view delegate






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

