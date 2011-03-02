//
//  DWPlacesContainerViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlacesContainerViewController.h"

//Declarations for private methods
//
@interface DWPlacesContainerViewController () 
- (void)addRightBarButtonItem;
- (void)removeRightBarButtonItem;

- (BOOL)isSelectedTab;

- (void)loadSelectedView:(UISegmentedControl*)segmentedControl;
- (void)hidePreviouslySelectedView:(UISegmentedControl*)segmentedControl;

@end



@implementation DWPlacesContainerViewController


#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)init {
	self = [super init];
	
	if (self) {
		self.title = PLACES_TAB_NAME;
		self.tabBarItem.image = [UIImage imageNamed:PLACES_TAB_IMAGE_NAME];
		
		_currentSelectedSegmentIndex = SELECTED_PLACES_INDEX;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tabBarSelectionChanged:) 
													 name:N_TAB_BAR_SELECTION_CHANGED
												   object:nil];
	}
    
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
			
	CGRect segmentedViewFrame = CGRectMake(0, 0, SEGMENTED_VIEW_WIDTH, SEGMENTED_VIEW_HEIGHT);
	UIView *segmentedView = [[UIView alloc] initWithFrame:segmentedViewFrame];
	segmentedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:SEGMENTED_VIEW_BACKGROUND_IMAGE_NAME]];	
	[self.view addSubview:segmentedView];
	[segmentedView release];
	
	
	// Create a segmented control.
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
	
	if(_currentSelectedSegmentIndex == POPULAR_PLACES_INDEX) {
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:SEGMENTED_CONTROL_POPULAR_ON_IMAGE_NAME] atIndex:0 animated:NO];
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:SEGMENTED_CONTROL_NEARBY_OFF_IMAGE_NAME] atIndex:1 animated:NO];
	}
	else {
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:SEGMENTED_CONTROL_POPULAR_OFF_IMAGE_NAME] atIndex:0 animated:NO];
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:SEGMENTED_CONTROL_NEARBY_ON_IMAGE_NAME] atIndex:1 animated:NO];
	}
	
	
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(5,8,SEGMENTED_PLACES_CONTROL_WIDTH,SEGMENTED_PLACES_CONTROL_HEIGHT);
	segmentedControl.backgroundColor = [UIColor	clearColor];
	segmentedControl.selectedSegmentIndex = _currentSelectedSegmentIndex;

	[segmentedControl addTarget:self
						 action:@selector(segmentedControllerSelectionChanged:)
			   forControlEvents:UIControlEventValueChanged];
	
	[segmentedView addSubview:segmentedControl];
	[segmentedControl release];
	
	
	
	
	if([DWSessionManager isSessionActive])
		[self addRightBarButtonItem];
		
	
	/*
	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
																	style:UIBarButtonItemStyleBordered
																   target:nil
																   action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	*/
	
	
	
	// Add sub views
	if(!popularViewController)
		popularViewController = [[DWPopularPlacesViewController alloc] initWithDelegate:self];
	[self.view addSubview:popularViewController.view];

	
	if(!nearbyViewController)
		nearbyViewController = [[DWNearbyPlacesViewController alloc] initWithDelegate:self];
	[self.view addSubview:nearbyViewController.view];
	

	[self loadSelectedView:segmentedControl];
}




// Adds a create place button to the right bar button item
//
- (void)addRightBarButtonItem {
	UIBarButtonItem *newPlaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																					target:self 
																					action:@selector(didPressCreateNewPlace:event:) ];
	self.navigationItem.rightBarButtonItem = newPlaceButton;
	[newPlaceButton release];
}


// Remove the compose button 
//
- (void)removeRightBarButtonItem {
	self.navigationItem.rightBarButtonItem = nil;
}


// Tests if its the currently selected tab
//
- (BOOL)isSelectedTab {
	return self.navigationController.tabBarController.selectedViewController == self.navigationController;
}


// Hides the view previously selected by the segmentControl
//
- (void)hidePreviouslySelectedView:(UISegmentedControl*)segmentedControl {
	if(_currentSelectedSegmentIndex == POPULAR_PLACES_INDEX) {
		[popularViewController viewIsDeselected];
		[segmentedControl setImage:[UIImage imageNamed:SEGMENTED_CONTROL_POPULAR_OFF_IMAGE_NAME] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
	else if(_currentSelectedSegmentIndex == NEARBY_PLACES_INDEX) {
		[nearbyViewController viewIsDeselected];
		[segmentedControl setImage:[UIImage imageNamed:SEGMENTED_CONTROL_NEARBY_OFF_IMAGE_NAME] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
}


// Loads a subview based on the currently selected button in the
// segmentedControl
//
- (void)loadSelectedView:(UISegmentedControl*)segmentedControl {	

	if(_currentSelectedSegmentIndex == POPULAR_PLACES_INDEX) {
		[popularViewController viewIsSelected];
		[segmentedControl setImage:[UIImage imageNamed:SEGMENTED_CONTROL_POPULAR_ON_IMAGE_NAME] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
	else if(_currentSelectedSegmentIndex == NEARBY_PLACES_INDEX) {
		[nearbyViewController viewIsSelected];
		[segmentedControl setImage:[UIImage imageNamed:SEGMENTED_CONTROL_NEARBY_ON_IMAGE_NAME] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
}


// Fired when the user switches selection on the segmentedController
//
- (void) segmentedControllerSelectionChanged:(id)sender {
	UISegmentedControl *segmentedController = (UISegmentedControl*)sender;

	[self hidePreviouslySelectedView:segmentedController];
	_currentSelectedSegmentIndex = segmentedController.selectedSegmentIndex;
	[self loadSelectedView:segmentedController];
}


// Users clicks on the create a new place button
//
- (void)didPressCreateNewPlace:(id)sender event:(id)event {
	DWNewPlaceViewController *newPlaceView = [[DWNewPlaceViewController alloc] initWithDelegate:self];
	[self.navigationController presentModalViewController:newPlaceView animated:YES];
	[newPlaceView release];
	 
}



#pragma mark -
#pragma mark Notification handlers

// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
	[self addRightBarButtonItem];
}



// Test is followed item view needs to be refreshed when the tab changes
//
- (void)tabBarSelectionChanged:(NSNotification*)notification {
}



#pragma mark -
#pragma mark ItemFeedViewControllerDelegate


// Fired when a place is selected in an item cell within a child of the ItemFeedViewController
//
- (void)placeSelected:(int)placeID {
	DWPlaceViewController *placeView = [[DWPlaceViewController alloc] initWithPlaceID:placeID withNewItemPrompt:NO andDelegate:self];
	[self.navigationController pushViewController:placeView animated:YES];
	[placeView release];
}


// Fired when a user is selected in an item cell within a child of the ItemFeedViewController
//
- (void)userSelected:(int)userID {
	DWUserViewController *userView = [[DWUserViewController alloc] initWithUserID:userID andDelegate:self];
	[self.navigationController pushViewController:userView animated:YES];
	[userView release];
}


// Fired when an attachment is clicked on in an item cell within a child of the ItemFeedViewController
//
- (void)attachmentSelected:(NSString *)url {
	DWImageViewController *imageView = [[DWImageViewController alloc] initWithImageURL:url];
	imageView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:imageView animated:YES];
	[imageView release];
}


// Fired when a url is clicked on in an item cell within a child of the ItemFeedViewController
//
- (void)urlSelected:(NSString *)url {
	DWWebViewController *webViewController = [[DWWebViewController alloc] 
											  initWithResourceURL:url]; 
	webViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}



#pragma mark -
#pragma mark NewPlaceViewControllerDelegate

// User cancels the new place creation process
//
- (void)newPlaceCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


// User just finished creating a new place
//
- (void)newPlaceCreated:(NSInteger)placeID {
	
	DWPlaceViewController *placeView = [[DWPlaceViewController alloc] initWithPlaceID:placeID
																	withNewItemPrompt:YES 
																		  andDelegate:self];
	[self.navigationController pushViewController:placeView animated:NO];
	[placeView release];
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {	
	NSLog(@"unload called on places container");
}


// The usual memory warning
//
- (void)didReceiveMemoryWarning {
	if(self.navigationController.tabBarController.selectedViewController != self.navigationController)
		[super didReceiveMemoryWarning];   
}


// The usual memory cleanup
// 
- (void)dealloc {
	[popularViewController release];
	[nearbyViewController release];
    [super dealloc];
}


@end
