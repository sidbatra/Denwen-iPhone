//
//  DWNearbyPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNearbyPlacesViewController.h"
#import "DWRequestsManager.h"
#import "DWPlacesCache.h"
#import "DWSession.h"
#import "DWConstants.h"

static NSInteger const kPlacesIndex			= 0;
static NSString* const kSearchBarText		= @"Search Nearby Places";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNearbyPlacesViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	
	self = [super initWithSearchType:YES
						withCapacity:kPlacesIndex + 1
						 andDelegate:delegate];
	
	if (self) {		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(nearbyPlacesCacheUpdated:) 
													 name:kNNearbyPlacesCacheUpdated
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.hidden	= YES;
	
	self.searchDisplayController.searchBar.placeholder = kSearchBarText;
}

//----------------------------------------------------------------------------------------------------
- (void)displayPlaces {
	if(_isLoadedOnce && [DWPlacesCache sharedDWPlacesCache].nearbyPlacesReady) {
		
		[_placeManager populatePreParsedPlaces:[[DWPlacesCache sharedDWPlacesCache] getNearbyPlaces]
									   atIndex:kPlacesIndex
									 withClear:YES];
		
		if([_placeManager totalPlacesAtRow:kPlacesIndex]) 
			_tableViewUsage = kTableViewAsData;
		else {
			self.messageCellText	= kMsgNoPlacesNearby;
			_tableViewUsage			= kTableViewAsMessage;
		}
		
		[self markEndOfPagination];
		[self.tableView reloadData];
		
		[self finishedLoadingPlaces];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadPlaces {
	[super loadPlaces];
		
	if(!_isLoadedOnce) {
		_isLoadedOnce = YES;
		[self displayPlaces];
	}
	else if(_isReloading) {
		/**
		 * On pull to refresh fire the request and let places cache handle it
		 */
		[[DWRequestsManager sharedDWRequestsManager] getNearbyPlaces];
	}
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
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)nearbyPlacesCacheUpdated:(NSNotification*)notification {
	[self displayPlaces];
}



@end

