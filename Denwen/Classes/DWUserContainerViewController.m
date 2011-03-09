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
		userViewController = [[DWUserViewController alloc] initWithUserID:currentUser.databaseID 
																 hideBackButton:YES 
																	andDelegate:self];
	[self.view addSubview:userViewController.view];
}





#pragma mark -
#pragma mark ItemFeedViewController delegate methods

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
	DWWebViewController *webViewController = [[DWWebViewController alloc] initWithResourceURL:url]; 
	webViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}





#pragma mark -
#pragma mark Memory management

//
//
- (void)viewDidUnload {	
	NSLog(@"unload called on user container");
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
	[userViewController release];
    
	[super dealloc];
}

@end
