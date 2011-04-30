//
//  DWPopularPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPopularPlacesViewController.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

static NSInteger const kCapacity				= 1;
static NSInteger const kPlacesIndex				= 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPopularPlacesViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super initWithCapacity:kCapacity 
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
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
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
	
	[self finishedLoading];
    [self markEndOfPagination];
	[self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------
- (void)popularPlacesError:(NSNotification*)notification {
	[self finishedLoading];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (void)loadData {
    [[DWRequestsManager sharedDWRequestsManager] getPopularPlaces:_currentPage];
}


@end

