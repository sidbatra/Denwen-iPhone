//
//  DWImageViewController.m
//  Denwen
//
//  Created by Gates 255 on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "DWImageViewController.h"


@implementation DWImageViewController



#pragma mark -
#pragma mark View lifecycle


// Init the view with initializations for the member variables
//
- (id)initWithImageURL:(NSString*)theURL {
	
	self = [super init];
    
	if (self) {
		url	 = [[NSString alloc] initWithString:theURL];
		
		NSArray *listItems = [url componentsSeparatedByString:@"/"];
		key = [[NSString alloc] initWithFormat:@"%@",[listItems objectAtIndex:[listItems count]-1]];
	}
    
	return self;
}


// Setup UI elements and being downloading the image
//
- (void)viewDidLoad {
	[DWGUIManager showSpinnerInNav:self];
		
	connection = [[DWURLConnection alloc] initWithDelegate:self];
	[connection fetchData:url withKey:key withCache:YES withActivitySpinner:YES];
}


// Change the navigation and status bar styles 
//
- (void)viewWillAppear:(BOOL)animated {
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}


// Reset the navigation and status bar style changes
//
- (void)viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


// Allow all orientations
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	return YES;
//}


// Refits the image when the device is about to be rotated
//
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[(DWImageView*)self.view fitImage:toInterfaceOrientation];
}


// Return the imageView as the view to be used for zooming and scrolling
//
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollView {
	return ((DWImageView*)self.view).imageView;
}



#pragma mark -
#pragma mark GURLConnection messages


// Display the image when it is successfully downloaded
//
-(void)finishedLoadingData:(NSMutableData *)data forInstanceID:(NSInteger)instanceID {
	[(DWImageView*)self.view setupImageView:data];
		
	[DWGUIManager hideSpinnnerInNav:self];
	
	[connection release];
    connection=nil;
}


// Display an alert when the image can't be downloaded from
// the filesystem
//
-(void)errorLoadingData:(NSError *)error forInstanceID:(NSInteger)instanceID {
	[DWGUIManager hideSpinnnerInNav:self];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"There was an error downloading this image, please try again later"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[connection release];
    connection=nil;
}



#pragma mark -
#pragma mark Memory management


// The usual did receive memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// The usual cleanup
//
- (void)dealloc {
	if (connection != nil) {
		[connection cancel];
		[connection release];
	}
	
	[url release];
	[key release];
    [super dealloc];
}

@end
