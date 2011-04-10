//
//  DWPlacesSearchResultsViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlacesSearchResultsViewController.h"
#import "DWPlacesCache.h"
#import "DWPlaceSearchResultCell.h"
#import "DWNewPlaceCell.h"
#import "DWLoadingCell.h"
#import "DWConstants.h"

static NSInteger const kSectionCount						= 1;
static NSInteger const kSpinnerCellIndex					= 1;
static NSInteger const kLoadingCellCount					= 3;
static NSInteger const kNewPlaceCellBufferCount				= 1;
static NSInteger const kRowHeight							= 44;
static NSString* const kPlaceSearchResultCellIdentifier		= @"PlaceSearchResultCell";
static NSString* const kNewPlaceCellIdentifier				= @"NewPlaceCell";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlacesSearchResultsViewController

@synthesize placesManager	= _placesManager;
@synthesize searchText		= _searchText;
@synthesize delegate		= _delegate;

- (id)init {
	self = [super init];
	
	if(self) {
		_tableViewUsage		= kTableViewAsSpinner;
		self.placesManager	= [DWPlacesCache sharedDWPlacesCache].placesManager;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(nearbyPlacesCacheUpdated:) 
													 name:kNNearbyPlacesCacheUpdated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followedPlacesCacheUpdated:) 
													 name:kNFollowedPlacesCacheUpdated
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	/**
	 * Clear local filtered places from the DWPlacesCache placesManager
	 */
	[self.placesManager clearFilteredPlaces:YES];
	
	self.placesManager	= nil;
	self.searchText		= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight		= kRowHeight;
	self.tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)filterPlacesBySearchText {
	
	if(!self.searchText || [self.searchText isEqualToString:kEmptyString]) {
		self.view.hidden = YES;
		return;
	}
	
	if([DWPlacesCache sharedDWPlacesCache].nearbyPlacesReady &&
	   [DWPlacesCache sharedDWPlacesCache].followedPlacesReady) {
		
		_tableViewUsage = kTableViewAsData;
		
		self.tableView.backgroundColor	= [UIColor colorWithRed:0.9294 green:0.9294 blue:0.9294 alpha:1.0];
		
		[self.placesManager filterPlacesForSearchText:self.searchText];
		[self.tableView reloadData];
	}
	
	self.view.hidden = NO;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)nearbyPlacesCacheUpdated:(NSNotification*)notification {
	if(!_newPlaceMode)
		[self filterPlacesBySearchText];
}

//----------------------------------------------------------------------------------------------------
- (void)followedPlacesCacheUpdated:(NSNotification*)notification {
	if(!_newPlaceMode)
		[self filterPlacesBySearchText];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSectionCount;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	
	if(_tableViewUsage == kTableViewAsSpinner)
		rows = kLoadingCellCount;
	else if(_tableViewUsage == kTableViewAsData)
		rows = [self.placesManager totalFilteredPlaces] + kNewPlaceCellBufferCount;
	
    return rows;
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [self.placesManager totalFilteredPlaces]) {
		
		DWPlaceSearchResultCell *cell = (DWPlaceSearchResultCell*)[tableView dequeueReusableCellWithIdentifier:kPlaceSearchResultCellIdentifier];
		
		if (!cell) {
			cell = [[[DWPlaceSearchResultCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
										   reuseIdentifier:kPlaceSearchResultCellIdentifier] autorelease];
			
		}
		
		DWPlace *place = [self.placesManager getFilteredPlace:indexPath.row];
		
		[cell reset];
		[cell setPlaceName:place.name];
		[cell setPlaceDetails:[place displayAddress]];
		
		return cell;
	}
	if(_tableViewUsage == kTableViewAsData && indexPath.row == [self.placesManager totalFilteredPlaces]) {
		
		DWNewPlaceCell *cell = (DWNewPlaceCell*)[tableView dequeueReusableCellWithIdentifier:kNewPlaceCellIdentifier];
		
		if (!cell) 
			cell = [[[DWNewPlaceCell alloc] initWithStyle:UITableViewCellStyleDefault 
										 reuseIdentifier:kNewPlaceCellIdentifier] autorelease];
		
		return cell;
	}
	else if(_tableViewUsage == kTableViewAsSpinner && indexPath.row == kSpinnerCellIndex) {
		
		DWLoadingCell *cell = (DWLoadingCell*)[tableView dequeueReusableCellWithIdentifier:kTVLoadingCellIdentifier];
		
		if (!cell) 
			cell = [[[DWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault 
										 reuseIdentifier:kTVLoadingCellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;	
		[cell.spinner startAnimating];
		
		return cell;
	}
	else {
		 cell = [tableView dequeueReusableCellWithIdentifier:kTVDefaultCellIdentifier];
		
		if (!cell) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:kTVDefaultCellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	
	return cell;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath 
								  animated:YES];
	
	if(_tableViewUsage == kTableViewAsData && indexPath.row < [self.placesManager totalFilteredPlaces]) {
		DWPlace *place = [self.placesManager getFilteredPlace:indexPath.row];
		[_delegate placeSelected:place];
		self.view.hidden = YES;
	}
	else if(_tableViewUsage == kTableViewAsData && indexPath.row == [self.placesManager totalFilteredPlaces]) {
		[_delegate newPlaceSelected];
		_newPlaceMode = YES;
		self.view.hidden = YES;
	}
}



@end

