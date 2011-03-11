

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
	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//
- (void)viewDidLoad {
    [super viewDidLoad];
	
	_followedRequestManager = [[DWRequestManager alloc] initWithDelegate:self andInstanceID:0];

	self.title = @"Places";
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

	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?email=%@&password=%@&ff=mobile",
						   FOLLOWED_PLACES_URI,
						   currentUser.email,
						   currentUser.encryptedPassword
						   ];
	[_followedRequestManager sendGetRequest:urlString];
	[urlString release];
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
		
	if([status isEqualToString:SUCCESS_STATUS]) {
		NSArray *places = [body objectForKey:PLACES_JSON_KEY];
		[_placeManager populatePlaces:places atIndex:instanceID];
				
		_isLoadedOnce = YES;
		_tableViewUsage = TABLE_VIEW_AS_DATA;
		
		[self markEndOfPagination];
		[self.tableView reloadData];
		[self finishedLoadingPlaces];
	}
	else {
			
	}
	
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
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
	
	if(_tableViewUsage == TABLE_VIEW_AS_DATA && !self.searchDisplayController.isActive)
		title = FOLLOWED_TITLE;
	
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
	
	[_followedRequestManager release];
	
	_selectPlaceDelegate = nil;
	
	[super dealloc];
}


@end


