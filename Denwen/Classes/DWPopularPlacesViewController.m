//
//  DWPopularPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPopularPlacesViewController.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

static NSString* const kSearchBarText			= @"Search All Places";
static NSInteger const kMinimumQueryLength		= 1;
static NSInteger const kCapacity				= 1;
static NSInteger const kPlacesIndex				= 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPopularPlacesViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super initWithNibName:kPlaceListViewControllerNib
						   bundle:nil 
					   searchType:NO 
					 withCapacity:kCapacity 
					  andDelegate:delegate];
	
	if (self) {
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGRect frame		= self.view.frame;
	frame.origin.y		= 0; 
	self.view.frame		= frame;
	
		
	self.searchDisplayController.searchBar.placeholder = kSearchBarText;
	
	
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

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)loadPlaces {
	[super loadPlaces];
	[[DWRequestsManager sharedDWRequestsManager] getPopularPlaces:_currentPage];
}

//----------------------------------------------------------------------------------------------------
- (void)searchPlaces:(NSString*)query {
	if(query.length >= kMinimumQueryLength)
		[[DWRequestsManager sharedDWRequestsManager] getSearchPlaces:query];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)popularPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		
		[_placeManager populatePlaces:places 
							  atIndex:kPlacesIndex 
							withClear:_isReloading];						
		
		_tableViewUsage = kTableViewAsData;
	}
	
	[self finishedLoadingPlaces];
	[self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------
- (void)popularPlacesError:(NSNotification*)notification {
	[self finishedLoadingPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)searchPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];

	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		
		[_placeManager populateFilteredPlaces:places];
		
		[self refreshFilteredPlacesUI];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)searchPlacesError:(NSNotification*)notification {
}


@end

