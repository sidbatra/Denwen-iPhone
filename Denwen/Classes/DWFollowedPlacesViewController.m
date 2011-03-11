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
		_isCurrentUser = [DWSessionManager isSessionActive] && currentUser.databaseID == _userID;
		_titleText = _isCurrentUser  ?
						[[NSString alloc] initWithString:@"Your Places"] :
						[[NSString alloc] initWithFormat:@"%@'s Places",userName];
						
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
	
	
	NSString *urlString = nil;	
	
	if([DWSessionManager isSessionActive])
		urlString = [[NSString alloc] initWithFormat:@"%@%d/places.json?ff=mobile&email=%@&password=%@",
							USER_SHOW_URI,
							_userID,
							currentUser.email,
							currentUser.encryptedPassword							
					 ];
	else
		urlString = [[NSString alloc] initWithFormat:@"%@%d/places.json?ff=mobile",
					 USER_SHOW_URI,
					 _userID
					 ];
		
	[_requestManager sendGetRequest:urlString];
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
	else {
		
	}
	
	[self finishedLoadingPlaces];
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
	[_titleText release];
	
    [super dealloc];
}


@end

