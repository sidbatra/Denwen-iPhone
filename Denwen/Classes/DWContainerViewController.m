//
//  DWContainerViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWContainerViewController.h"
#import "DWUserViewController.h"
#import "DWPlaceViewController.h"
#import "DWImageViewController.h"
#import "DWWebViewController.h"
#import "DWVideoViewController.h"
#import "NSString+Helpers.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWContainerViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithTabBarController:(UIViewController*)theCustomTabBarController {
	self = [super init];
	
	if (self) {		
		
		customTabBarController = theCustomTabBarController;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(denwenURLOpened:) 
													 name:kNDenwenURLOpened
												   object:nil];
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	//if(launchURL) {
	//	[self processLaunchURL:[launchURL absoluteString]];
	//	launchURL = nil;
	//}
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	if(![self isSelectedTab])
		[super didReceiveMemoryWarning];   
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isSelectedTab {
	return self.navigationController.tabBarController.selectedViewController == self.navigationController;
}

//----------------------------------------------------------------------------------------------------
-(void)displaySelectedPlace:(DWPlace*)place {
	DWPlaceViewController *placeView = [[DWPlaceViewController alloc] initWithPlace:place 
																		andDelegate:self];
	[self.navigationController pushViewController:placeView animated:YES];
	[placeView release];
}

//----------------------------------------------------------------------------------------------------
- (void)processLaunchURL:(NSString*)url {
	//if([url hasPrefix:DENWEN_URL_PREFIX])
	//	[self displaySelectedPlace:[url substringFromIndex:[DENWEN_URL_PREFIX length]]];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)denwenURLOpened:(NSNotification*)notification {
	if([self isSelectedTab]) {
		NSString *url = (NSString*)[notification object];
		[self processLaunchURL:url];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark ItemFeedViewControllerDelegate

//----------------------------------------------------------------------------------------------------
- (void)placeSelected:(DWPlace*)place {
	[self displaySelectedPlace:place];
}

//----------------------------------------------------------------------------------------------------
- (void)userSelected:(DWUser*)user {
	DWUserViewController *userView = [[DWUserViewController alloc] initWithUser:user
																	  andDelegate:self];
	[self.navigationController pushViewController:userView 
										 animated:YES];
	[userView release];
}

//----------------------------------------------------------------------------------------------------
- (void)attachmentSelected:(NSString*)url withIsImageType:(BOOL)isImage {
	
	if(isImage) {
		DWImageViewController *imageView = [[DWImageViewController alloc] initWithImageURL:url];
		imageView.hidesBottomBarWhenPushed = YES;
		
		[self.navigationController pushViewController:imageView 
											 animated:YES];
		[imageView release];
	}
	else {
		DWVideoViewController *videoView = [[DWVideoViewController alloc] initWithMediaURL:url];
		videoView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[customTabBarController presentMoviePlayerViewControllerAnimated:videoView];
		[videoView release];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)urlSelected:(NSString *)url {
	DWWebViewController *webViewController = [[DWWebViewController alloc] initWithWebPageURL:url]; 
	webViewController.hidesBottomBarWhenPushed = YES;
	
	[self.navigationController pushViewController:webViewController 
										 animated:YES];
	
	[webViewController release];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIControlEvents

//----------------------------------------------------------------------------------------------------
- (void)didTapBackButton:(id)sender event:(id)event {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
