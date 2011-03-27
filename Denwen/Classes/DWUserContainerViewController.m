//
//  DWUserContainerViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUserContainerViewController.h"


@implementation DWUserContainerViewController


#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self) {
		self.title = PROFILE_TAB_NAME;
		self.tabBarItem.image = [UIImage imageNamed:PROFILE_TAB_IMAGE_NAME];
	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add subviews
	//
	if(!userViewController)
		userViewController = [[DWUserViewController alloc] initWithUserID:[DWSession sharedDWSession].currentUser.databaseID 
																 hideBackButton:YES 
																	andDelegate:self];
	[self.view addSubview:userViewController.view];
}



#pragma mark -
#pragma mark Memory management

//
//
- (void)viewDidUnload {	
	NSLog(@"unload called on user container");
}


// The usual memory cleanup
// 
- (void)dealloc {
	[userViewController release];
    
	[super dealloc];
}

@end
