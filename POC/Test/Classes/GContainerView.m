//
//  GContainerView.m
//  Test
//
//  Created by Deepak Rao on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GContainerView.h"



@implementation GContainerView

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor redColor];
	
	firstController = [[GItemsViewController alloc] init];
	secondController = [[GFollowedViewController alloc] init];
	thirdController = [[GPopularViewController alloc] init];
	
    [super viewDidLoad];
	NSArray *itemArray = [NSArray arrayWithObjects: @"Nearby", @"Followed", @"Popular", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
	
	segmentedControl.frame = CGRectMake(35, 200, 250, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = 0;
	
	[segmentedControl addTarget:self
						 action:@selector(pickOne:)
			   forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
	[self.view addSubview:firstController.view];
	[firstController viewWillAppear:NO];
	previousSelection = 0;
}


- (void) pickOne:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	if (segmentedControl.selectedSegmentIndex == 0 && previousSelection != 0) {
		if (previousSelection = 1) {
			[secondController.view removeFromSuperview];
		}
		else {
			[thirdController.view removeFromSuperview];
		}	
		[self.view addSubview:firstController.view];
		[firstController viewWillAppear:NO];
		previousSelection = 0;
	}
	else if (segmentedControl.selectedSegmentIndex == 1 && previousSelection != 1) {
		if (previousSelection == 0) {
			[firstController.view removeFromSuperview];			
		}
		else {
			[thirdController.view removeFromSuperview];
		}
		[self.view addSubview:secondController.view];
		[secondController viewWillAppear:NO];
		previousSelection = 1;
	}
	else if (segmentedControl.selectedSegmentIndex == 2 && previousSelection != 2) {
		if (previousSelection == 0) {
			[firstController.view removeFromSuperview];	
		}
		else {
			[secondController.view removeFromSuperview];
		}
		[self.view addSubview:thirdController.view];
		[thirdController viewWillAppear:NO];
		previousSelection = 2;
	}
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 return YES;
 }*/


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[firstController release];
	[secondController release];
    [super dealloc];
}


@end
