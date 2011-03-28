//
//  DWFollowedPlacesViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWFollowedPlacesViewController.h"

//Declarations for private methods
//
@interface DWFollowedPlacesViewController () 
@end


@implementation DWFollowedPlacesViewController



#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate withUserName:(NSString*)userName andUserID:(NSInteger)userID {
	self = [super initWithNibName:@"DWPlaceListViewController" bundle:nil searchType:YES withCapacity:1 andDelegate:delegate];
	
	if (self) {		
		_userID = userID;
		_isCurrentUser = [[DWSession sharedDWSession] isActive] && [DWSession sharedDWSession].currentUser.databaseID == _userID;
		_titleText = _isCurrentUser  ?
						[[NSString alloc] initWithString:@"Your Places"] :
						[[NSString alloc] initWithFormat:@"%@'s Places",userName];
		
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


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.hidden = NO;
	self.title = _titleText;
	
	NSString *searchString = [[NSString alloc] initWithFormat:@"Search %@",_titleText];
	self.searchDisplayController.searchBar.placeholder = searchString;
	[searchString release];
	
	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
																	style:UIBarButtonItemStyleBordered
																   target:nil
																   action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	[self viewIsSelected];
}


// Called when the controller becomes selected in the container
//
- (void)viewIsSelected {
	_tableViewUsage = TABLE_VIEW_AS_SPINNER;
	[self.tableView reloadData];
	
	[self loadPlaces];
}




#pragma mark -
#pragma mark Methods to obtain places from the server


// Send a request to load popoular places
//
- (void)loadPlaces {
	[super loadPlaces];
	
	[[DWRequestsManager sharedDWRequestsManager] requestUserPlaces:_userID];	
}



#pragma mark -
#pragma mark RequestManager

- (void)userPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];

	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		[_placeManager populatePlaces:places atIndex:0];
		
		
		if([_placeManager totalPlacesAtRow:0]) {
			_tableViewUsage = TABLE_VIEW_AS_DATA;	
			_isLoadedOnce = YES;
		}
		else {
			if(_isCurrentUser)
				self.messageCellText = FOLLOW_NO_PLACES_SELF_MSG;
			else
				self.messageCellText = FOLLOW_NO_PLACES_MSG;
			
			_tableViewUsage = TABLE_VIEW_AS_MESSAGE;
		}
		
		[self markEndOfPagination];
		[self.tableView reloadData];
		
	}
	
	[self finishedLoadingPlaces];
}

- (void)userPlacesError:(NSNotification*)notification {
	[self finishedLoadingPlaces];
}





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
	[_titleText release];
	
    [super dealloc];
}


@end

