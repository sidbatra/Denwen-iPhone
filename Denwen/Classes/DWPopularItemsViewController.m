//
//  DWPopularItemsViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPopularItemsViewController.h"

//Declarations for private methods
//
@interface DWPopularItemsViewController () 
@end



@implementation DWPopularItemsViewController


#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)initWithDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
		self.view.hidden = YES;
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

// Fetches recent items from places being followed by the current user
//
- (BOOL)loadItems {
	[super loadItems];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@?page=%d&ff=mobile",
							POPULAR_ITEMS_URI,
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
-(void)didFinishRequest:(NSString*)status withBody:(NSDictionary*)body 
			withMessage:(NSString*)message withInstanceID:(int)instanceID {
	
	if([status isEqualToString:SUCCESS_STATUS]) {
		
		NSArray *items = [body objectForKey:ITEMS_JSON_KEY];		
		[_itemManager populateItems:items withBuffer:NO withClear:_reloading];
		
		_tableViewUsage = TABLE_VIEW_AS_DATA;
	}
	else {
		
	}
	
	[super finishedLoadingItems];
	[self.tableView reloadData];
}


// Fired when an error happens during the request
//
-(void)errorWithRequest:(NSError*)error forInstanceID:(int)instanceID {
	[super finishedLoadingItems];
}



#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[super viewDidUnload];
}

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

