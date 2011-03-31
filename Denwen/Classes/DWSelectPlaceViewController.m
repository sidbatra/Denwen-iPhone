

//
//  DWSelectPlaceViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWSelectPlaceViewController.h"


//Declarations for private methods
//
@interface DWSelectPlaceViewController () 
- (BOOL)isSpecialMessageSection:(NSInteger)row;
- (void)populatePlaces:(NSArray*)places;
@end


@implementation DWSelectPlaceViewController

//@synthesize tableView;


#pragma mark -
#pragma mark View lifecycle


// Init the class and set the delegate member variable
//
- (id)initWithDelegate:(id)delegate {
	
	self = [super initWithNibName:@"DWPlaceListViewController" bundle:nil searchType:YES withCapacity:1 andDelegate:delegate];
	
	if(self) {
		_selectPlaceDelegate = delegate;
		self.view.hidden = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPlacesLoaded:) 
													 name:kNUserPlacesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPlacesError:) 
													 name:kNUserPlacesError
												   object:nil];
	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//
- (void)viewDidLoad {
    [super viewDidLoad];
	

	self.title = @"Your Places";
	self.searchDisplayController.searchBar.placeholder = @"Search Your Places";
	self.navigationItem.prompt = @"Choose a place to post at";
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				  target:self 
																				  action:@selector(didPressCancelButton:event:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];	
	
	[self loadPlaces];
}


// User clicks the cancel button
//
- (void)didPressCancelButton:(id)sender event:(id)event {
	[_selectPlaceDelegate selectPlaceCancelled];
}


// Tests if the given section only contains a special message row deployed when
// the number of rows in a section are empty
//
- (BOOL)isSpecialMessageSection:(NSInteger)section {
	return _tableViewUsage == TABLE_VIEW_AS_DATA && !self.searchDisplayController.isActive && ![_placeManager totalPlacesAtRow:section];
}



#pragma mark -
#pragma mark Methods to obtain places from the server


// Send a request to load popoular places
//
- (void)loadPlaces {
	[super loadPlaces];
	
	[[DWRequestsManager sharedDWRequestsManager] getUserPlaces:[DWSession sharedDWSession].currentUser.databaseID];	
}


// Populate places based on the given JSON array
//
- (void)populatePlaces:(NSArray*)places {
	[_placeManager populatePlaces:places atIndex:0];
	
	_isLoadedOnce = YES;
	_tableViewUsage = TABLE_VIEW_AS_DATA;
	
	[self markEndOfPagination];
	[self.tableView reloadData];
	[self finishedLoadingPlaces];
}


#pragma mark -
#pragma mark RequestManager Delegate methods


- (void)userPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != [DWSession sharedDWSession].currentUser.databaseID)
		return;
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		[self populatePlaces:places];
	}
}	

- (void)userPlacesError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != [DWSession sharedDWSession].currentUser.databaseID)
		return;
	
	[self finishedLoadingPlaces];
}



#pragma mark -
#pragma mark Table view data source


// Override the number of rows in section method to display message cells when there are no nearby or followed
// places
//
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	
	if([self isSpecialMessageSection:section])
		rows = 1;
	else
		rows = [super tableView:theTableView numberOfRowsInSection:section];
	
	return rows;
}


// Create headers for the needed sections
//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = @"";
	
	//if(_tableViewUsage == TABLE_VIEW_AS_DATA && !self.searchDisplayController.isActive)
	//	title = FOLLOWED_TITLE;
	
	return title;
}


// Override cellFowRowAtIndexPath to chagne the cell accessory type
//
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if([self isSpecialMessageSection:indexPath.section]) {		
	   DWMessageCell *cell = (DWMessageCell*)[theTableView dequeueReusableCellWithIdentifier:MESSAGE_CELL_IDENTIFIER];
	   
	   if (!cell) 
		   cell = [[[DWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MESSAGE_CELL_IDENTIFIER] autorelease];
	   
	   cell.selectionStyle = UITableViewCellSelectionStyleNone;	
		
	   cell.textLabel.text = FOLLOW_NO_PLACES_SELF_MSG;
	   
	   return cell;
	}
	else
		cell = [super tableView:theTableView cellForRowAtIndexPath:indexPath];
	   
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}


// Override the click handler to wrap the selection message in a custom delegate
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(![self isSpecialMessageSection:indexPath.section]) {
		DWPlace *place = self.searchDisplayController.isActive ? 
		[_placeManager getFilteredPlace:indexPath.row] :
		[_placeManager getPlaceAtRow:indexPath.section andColumn:indexPath.row];
		
		[self.searchDisplayController setActive:NO animated:NO]; //dismiss the searchDisplayController -- crashes otherwise
		[_selectPlaceDelegate selectPlaceFinished:[[[NSString alloc] initWithString:place.name] autorelease] andPlaceID:place.databaseID];
		
		 
		//Deselect the currently selected row 
		/*if(self.searchDisplayController.isActive)
			[self.searchDisplayController.searchResultsTableView 
			 deselectRowAtIndexPath:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow] animated:YES];
		else
			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];*/
	}
}



#pragma mark -
#pragma mark Memory management

// The usual memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// The usual memory cleanup
//
- (void)dealloc {
	
	//[_followedRequestManager release];
	
	_selectPlaceDelegate = nil;
	
	[super dealloc];
}


@end


