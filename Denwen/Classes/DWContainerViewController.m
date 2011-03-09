//
//  DWContainerViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWContainerViewController.h"


@implementation DWContainerViewController



// Tests if its the currently selected tab
//
- (BOOL)isSelectedTab {
	return self.navigationController.tabBarController.selectedViewController == self.navigationController;
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


//
//
- (void)viewDidUnload {
    [super viewDidUnload];
}


// Launch a did receive memory warning if its not the currently selected tab
//
- (void)didReceiveMemoryWarning {
	if(![self isSelectedTab])
		[super didReceiveMemoryWarning];   
}


// The usual dealloc
//
- (void)dealloc {
    [super dealloc];
}


@end
