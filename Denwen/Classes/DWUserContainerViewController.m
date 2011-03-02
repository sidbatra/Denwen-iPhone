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
- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];
	
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
		
	/*
	UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TITLE
																	style:UIBarButtonItemStyleBordered
																   target:nil
																   action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	*/
}



#pragma mark -
#pragma mark Mmory Management

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
