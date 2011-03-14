//
//  DWContainerViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWContainerViewController.h"


@interface DWContainerViewController() 
- (void)displaySelectedPlace:(NSString*)placeHashedID;
- (void)processLaunchURL:(NSString*)url;
@end


@implementation DWContainerViewController




#pragma mark -
#pragma mark View lifecycle


// Init the view along with its member variables 
//
- (id)init {
	self = [super init];
	
	if (self) {		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(denwenURLOpened:) 
													 name:N_DENWEN_URL_OPENED
												   object:nil];
		
	}
    
	return self;
}


// Test if a launchURL exists on viewDidLoad logic
//
- (void)viewDidLoad {
	if(launchURL) {
		[self processLaunchURL:[launchURL absoluteString]];
		launchURL = nil;
	}
}


// Tests if its the currently selected tab
//
- (BOOL)isSelectedTab {
	return self.navigationController.tabBarController.selectedViewController == self.navigationController;
}


// Push a placeViewController onto the nav stack 
//
-(void)displaySelectedPlace:(NSString*)placeHashedID {
	DWPlaceViewController *placeView = [[DWPlaceViewController alloc] initWithPlaceID:placeHashedID withNewItemPrompt:NO andDelegate:self];
	[self.navigationController pushViewController:placeView animated:YES];
	[placeView release];
}


// Dispatch logic when a URL is opened by the application
//
- (void)processLaunchURL:(NSString*)url {
	if([url hasPrefix:DENWEN_URL_PREFIX])
		[self displaySelectedPlace:[url substringFromIndex:[DENWEN_URL_PREFIX length]]];
}



#pragma mark -
#pragma mark Notification handlers


// Refresh UI when user logs in
//
- (void)denwenURLOpened:(NSNotification*)notification {
	if([self isSelectedTab]) {
		NSString *url = (NSString*)[notification object];
		[self processLaunchURL:url];
	}
}



#pragma mark -
#pragma mark ItemFeedViewControllerDelegate


// Fired when a place is selected in an item cell within a child of the ItemFeedViewController
//
- (void)placeSelected:(NSString*)placeHashedID {
	[self displaySelectedPlace:placeHashedID];
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
- (void)attachmentSelected:(NSString*)url withIsImageType:(BOOL)isImage {
	
	if(isImage) {
		DWImageViewController *imageView = [[DWImageViewController alloc] initWithImageURL:url];
		imageView.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:imageView animated:YES];
		[imageView release];
	}
	else {
		DWVideoViewController *videoView = [[DWVideoViewController alloc] initWithMediaURL:url];
		videoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self.navigationController presentModalViewController:videoView animated:YES];
		[videoView release];
	}

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
