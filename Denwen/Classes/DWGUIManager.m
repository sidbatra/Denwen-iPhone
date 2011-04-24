//
//  DWGUIManager.m
//  Denwen
//
//  Created by Deepak Rao on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWGUIManager.h"

static NSString* const kImgBackButton                   = @"button_back.png";
static NSString* const kImgBackButtonActive             = @"button_back.png";
static NSString* const kImgPlaceDetailsButton           = @"button_map.png";
static NSString* const kImgPlaceDetailsButtonActive     = @"button_map.png";

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


// Gets the current status bar orientation
//
+ (UIInterfaceOrientation)getCurrentOrientation {
	return [UIApplication sharedApplication].statusBarOrientation;
}

// Custom back button for the app
//
+ (UIBarButtonItem*)customBackButton:(id)target {
	UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:kImgBackButton] forState:UIControlStateNormal];
	 [button setBackgroundImage:[UIImage imageNamed:kImgBackButtonActive] forState:UIControlStateHighlighted];
	[button addTarget:target action:@selector(didTapBackButton:event:) 
		   forControlEvents:UIControlEventTouchUpInside];
	[button setFrame:CGRectMake(0, 0, 55, 44)];
	
	return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

// Place details navigation bar button
//
+ (UIBarButtonItem*)placeDetailsButton:(id)target {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setBackgroundImage:[UIImage imageNamed:kImgPlaceDetailsButton] 
                      forState:UIControlStateNormal];
    
    [button setBackgroundImage:[UIImage imageNamed:kImgPlaceDetailsButtonActive] 
                      forState:UIControlStateHighlighted];
    
	[button addTarget:target 
               action:@selector(didTapPlaceDetailsButton:event:) 
     forControlEvents:UIControlEventTouchUpInside];
    
	[button setFrame:CGRectMake(0, 0, 55, 44)];
	
	return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

// User profile pic navigation bar button
//
+ (UIBarButtonItem*)profilePicButton:(id)target withBackgroundImage:(UIImage*)image {
	UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setBackgroundImage:image 
                      forState:UIControlStateNormal];
    
	[button addTarget:target 
               action:@selector(didTapSmallUserImage:event:) 
     forControlEvents:UIControlEventTouchUpInside];
	
    [button setFrame:CGRectMake(5, 0, 55, 44)];
	
	return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
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

