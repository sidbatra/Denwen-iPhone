//
//  DWNearbyPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNearbyPlacesViewController.h"
#import "DWRequestsManager.h"
#import "DWConstants.h"

static NSInteger const kCapacity			= 1;
static NSString* const kSearchBarText		= @"Search All Places";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNearbyPlacesViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	
	self = [super initWithNibName:kPlaceListViewControllerNib 
						   bundle:nil
					   searchType:YES
					 withCapacity:kCapacity
					  andDelegate:delegate];
	
	if (self) {		
		
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newPlaceParsed:) 
													 name:kNNewPlaceParsed 
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGRect frame		= self.view.frame;
	frame.origin.y		= kSegmentedPlacesViewHeight; 
	frame.size.height	= frame.size.height - kSegmentedPlacesViewHeight;
	self.view.frame		= frame;
	
	self.view.hidden = YES;
	
	self.searchDisplayController.searchBar.placeholder = kSearchBarText;
}

//----------------------------------------------------------------------------------------------------
- (void)loadPlaces {
	[super loadPlaces];
	
	[[DWRequestsManager sharedDWRequestsManager] getNearbyPlaces];
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
- (void)applicationEnteringForeground:(NSNotification*)notification {
	if(_isLoadedOnce)
		[self hardRefresh];
}

//----------------------------------------------------------------------------------------------------
- (void)newPlaceParsed:(NSNotification*)notification {
	DWPlace *place = (DWPlace*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyPlace];
	
	if(_isLoadedOnce && 
		[[DWSession sharedDWSession].location distanceFromLocation:place.location] <= kLocNearbyRadius)	
		[self addNewPlace:place];
}

//----------------------------------------------------------------------------------------------------
- (void)nearbyPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		[_placeManager populatePlaces:places atIndex:kCapacity-1];
		
		
		if([_placeManager totalPlacesAtRow:kCapacity-1]) 
			_tableViewUsage = kTableViewAsData;
		else {
			self.messageCellText = kMsgNoPlacesNearby;
			_tableViewUsage = kTableViewAsMessage;
		}
		
		_isLoadedOnce = YES;
		
		[self markEndOfPagination];
		[self.tableView reloadData];
	}	
	
	[self finishedLoadingPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)nearbyPlacesError:(NSNotification*)notification {
	[self finishedLoadingPlaces];
}


@end

