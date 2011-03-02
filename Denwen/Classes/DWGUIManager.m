//
//  DWGUIManager.m
//  Denwen
//
//  Created by Deepak Rao on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWGUIManager.h"


@implementation DWGUIManager


#pragma mark -
#pragma mark Screen size and orientation helpers


// Returns the current screen size based on the orientation of the device
//
+ (CGSize)currentScreenSize:(UIInterfaceOrientation)toInterfaceOrientation {
	CGSize size;
	
	if(toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
		size = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
	else
		size = CGSizeMake(SCREEN_ROTATED_WIDTH, SCREEN_ROTATED_HEIGHT);
	
	return size;
}


// Partial Function for currentScreensize
//
+ (CGSize)currentScreenSize {
	return [self currentScreenSize:[UIApplication sharedApplication].statusBarOrientation];
}


//Gets the current status bar orientation
//
+ (UIInterfaceOrientation)getCurrentOrientation {
	return [UIApplication sharedApplication].statusBarOrientation;
}



#pragma mark -
#pragma mark Spinner


// Start animating the spinner while the content is loaded in the background
//
+ (void)showSpinnerInNav:(id)target {
	[target navigationItem].rightBarButtonItem = nil;
	CGRect frame = CGRectMake(0.0, 0.0, 18.0, 18.0);
	
	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[loading startAnimating];
	[loading sizeToFit];
	
	UIBarButtonItem *spinner = [[UIBarButtonItem alloc] initWithCustomView:loading];
	[loading release];
	
	//Add the spinner to the nav bar
	[target navigationItem].rightBarButtonItem = spinner; 
	[spinner release];
}


// End the spinner animation and optionally replace with a refresh button
//
+ (void)hideSpinnnerInNav:(id)target {	
	[target navigationItem].rightBarButtonItem = nil;
}

@end

