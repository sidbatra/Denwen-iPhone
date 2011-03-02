//
//  DWNearbyItemsViewController.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWNearbyItemsViewController.h"

//Declarations for private methods
//
@interface DWNearbyItemsViewController () 
@end


@implementation DWNearbyItemsViewController


#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		self.view.hidden = YES;

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemCreated:) 
													 name:N_NEW_ITEM_CREATED 
												   object:nil];
	}
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.hidden = YES;
}


// Called when the controller becomes selected in the container
//
- (void)viewIsSelected {
	
	self.view.hidden = NO;
	
	//TODO: or if a lot of time has expired
	
	if(!_isLoadedOnce) {
		[self loadItems];
		_isLoadedOnce = YES;
	}
	
}


// Called when the controller is deselected from the container
//
- (void)viewIsDeselected {
	self.view.hidden = YES;
}



#pragma mark -
#pragma mark ItemManager 

// Fetches the nearby items from the server via the itemManager object
// and repopulates the UI
//
- (BOOL)loadItems {
	[super loadItems];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?lat=%f&lon=%f&page=%d&ff=mobile",
						   NEARBY_ITEMS_URI,
						   currentUserLocation.coordinate.latitude,
						   currentUserLocation.coordinate.longitude,
						   _currentPage
						   ];
	
	[_requestManager sendGetRequest:urlString];
	[urlString release];
	
	return YES;
}



#pragma mark -
#pragma mark RequestManager Delegate methods


// Fired when request manager has successfully parsed a request
//
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body withMessage:(NSString*)message 
		 withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		NSArray *items = [body objectForKey:ITEMS_JSON_KEY];
		[_itemManager populateItems:items withBuffer:NO withClear:_reloading];
		
		
		if(![_itemManager totalItems]) {
			self.messageCellText = NO_ITEMS_NEARBY_MSG;
			_tableViewUsage = TABLE_VIEW_AS_MESSAGE;
		}
		else
			_tableViewUsage = TABLE_VIEW_AS_DATA;
		
	}
	else {
		
	}
	
	[self finishedLoadingItems];
	[self.tableView reloadData];
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	[self finishedLoadingItems];
}



#pragma mark -
#pragma mark Notification handlers


// New item created
//
- (void)newItemCreated:(NSNotification*)notification {
	DWItem *item = (DWItem*)[notification object];
	
	if(_isLoadedOnce &&  [currentUserLocation distanceFromLocation:item.place.location] <= LOCATION_NEARBY_RADIUS)
		[self addNewItem:item atIndex:0];
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
    [super dealloc];
}


@end

