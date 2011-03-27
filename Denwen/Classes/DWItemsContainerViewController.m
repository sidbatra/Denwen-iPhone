//
//  DWItemsContainerViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemsContainerViewController.h"

//Declarations for private methods
//
@interface DWItemsContainerViewController () 
- (void)addRightBarButtonItem;
- (void)removeRightBarButtonItem;

- (void)updateBadgeValueOnTabItem;

- (void)conditionallyRefreshFollowedItems;
@end



@implementation DWItemsContainerViewController


#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)init {
	self = [super init];
	
	if (self) {		
		self.title = POSTS_TAB_NAME;
		self.tabBarItem.image = [UIImage imageNamed:POSTS_TAB_IMAGE_NAME];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userLogsIn:) 
													 name:N_USER_LOGS_IN
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newApplicationBadgeNumber:) 
													 name:N_NEW_APPLICATION_BADGE_NUMBER
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followedItemsRead:) 
													 name:N_FOLLOWED_ITEMS_READ
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followedItemsLoaded:) 
													 name:N_FOLLOWED_ITEMS_LOADED
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tabBarSelectionChanged:) 
													 name:N_TAB_BAR_SELECTION_CHANGED
												   object:nil];
		
		if (&UIApplicationDidEnterBackgroundNotification != NULL) {
			[[NSNotificationCenter defaultCenter] addObserver:self 
													 selector:@selector(applicationEnteringBackground:) 
														 name:UIApplicationDidEnterBackgroundNotification
													   object:nil];
		}
		
		
	}
    
	return self;
}


// Setup UI elements after the view is done loading
//
- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	if([[DWSession sharedDWSession] isActive])
		[self addRightBarButtonItem];
	
	
	/*
	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
																	style:UIBarButtonItemStyleBordered
																   target:nil
																   action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	*/
	
	//Add subviews
	//
	if(!followedViewController)
		followedViewController = [[DWFollowedItemsViewController alloc] initWithDelegate:self];
	[self.view addSubview:followedViewController.view];
	[followedViewController viewIsSelected];
}


// Mark unread items as read if the followed items view is currently visible
//
- (void)viewDidDisappear:(BOOL)animated {
	[DWNotificationHelper followedItemsRead];
}


// Adds a compose button to the right bar button item
//
- (void)addRightBarButtonItem {
	UIBarButtonItem *newItemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
																				   target:self 
																				   action:@selector(didPressCreateNewItem:event:) ];
	self.navigationItem.rightBarButtonItem = newItemButton;
	[newItemButton release];
}


// Remove the compose button 
//
- (void)removeRightBarButtonItem {
	self.navigationItem.rightBarButtonItem = nil;
}


// Update the badge value on the Posts tab bar item
//
- (void)updateBadgeValueOnTabItem {
	if(followedItemsUnreadCount)
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",followedItemsUnreadCount];
	else
		self.tabBarItem.badgeValue = nil;
}


// Users clicks on the create a new item button
//
- (void)didPressCreateNewItem:(id)sender event:(id)event {
	DWSelectPlaceViewController *selectPlaceView = [[DWSelectPlaceViewController alloc] initWithDelegate:self];																																							
	
	UINavigationController *selectPlaceNav = [[UINavigationController alloc] initWithRootViewController:selectPlaceView];
	[selectPlaceView release];
	
	[self.navigationController presentModalViewController:selectPlaceNav animated:YES];
	[selectPlaceNav release];
}


// Refresh the followed items view based on pre defined criteria
//
- (void)conditionallyRefreshFollowedItems {
	if([self isSelectedTab] && currentUserFollowedItemsRefresh)
		[followedViewController viewIsSelected];
}



#pragma mark -
#pragma mark Notification handlers

// Refresh UI when user logs in
//
- (void)userLogsIn:(NSNotification*)notification {
}


// Handle arrival of a new application badge number when the application resumes or starts
//
- (void)newApplicationBadgeNumber:(NSNotification*)notification {
	if([(NSString*)[notification object] isEqualToString:BADGE_NOTIFICATION_BACKGROUND])
		[self updateBadgeValueOnTabItem];
}


// Fired when followed items have been read by the user
//
- (void)followedItemsRead:(NSNotification*)notification {
	self.tabBarItem.badgeValue = nil;
}


// Fired when followed items have been loaded 
//
- (void)followedItemsLoaded:(NSNotification*)notification {
	[self updateBadgeValueOnTabItem];
}


// Test is followed item view needs to be refreshed when the tab changes
//
- (void)tabBarSelectionChanged:(NSNotification*)notification {
	[self conditionallyRefreshFollowedItems];
	
	if(_isCurrentSelectedTab && ![self isSelectedTab])
		[DWNotificationHelper followedItemsRead];
	
	_isCurrentSelectedTab = [self isSelectedTab];
	
	// Force the UI to point to followed items if a tab is changed and there are unread
	if(_isCurrentSelectedTab && followedItemsUnreadCount) {		
		[self.navigationController popToRootViewControllerAnimated:NO];
		[followedViewController scrollToTop];
	}
}


// Mark items as read if the app goes into the background on the followedItems
//
- (void)applicationEnteringBackground:(NSNotification *)aNotification {
	if([self isSelectedTab])
		[DWNotificationHelper followedItemsRead];
}



#pragma mark -
#pragma mark SelectPlaceViewControllerDelegate 


// User cancels the select place view
//
- (void)selectPlaceCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


// User selects a place to post to
//
- (void)selectPlaceFinished:(NSString*)placeName andPlaceID:(NSInteger)placeID {
	[self.navigationController dismissModalViewControllerAnimated:NO];
	
	DWNewItemViewController *newItemView = [[DWNewItemViewController alloc] initWithDelegate:self 
																			   withPlaceName:placeName
																				 withPlaceID:placeID
																			   withForcePost:NO];
	[self.navigationController presentModalViewController:newItemView animated:NO];
	[newItemView release];
}



#pragma mark -
#pragma mark NewItemViewController delegate events


// Fired when user cancels the new item creation
//
- (void)newItemCancelled {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


// Fired when the new has successfully created a new item for this place
//
- (void)newItemCreationFinished {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {	
	NSLog(@"unload called on items container");
}


// The usual memory cleanup
// 
- (void)dealloc {
	[followedViewController release];
    
	[super dealloc];
}


@end
