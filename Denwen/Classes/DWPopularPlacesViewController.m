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
	self = [super initWithSearchType:NO 
					 withCapacity:kCapacity 
					  andDelegate:delegate];
	
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(popularPlacesLoaded:) 
													 name:kNPopularPlacesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(popularPlacesError:) 
													 name:kNPopularPlacesError
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
		
	self.searchDisplayController.searchBar.placeholder = kSearchBarText;
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
	//[[DWRequestsManager sharedDWRequestsManager] getPopularPlaces:_currentPage];
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



@end

