    //
//  DWVideoViewController.m
//  Denwen
//
//  Created by Siddharth Batra on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWVideoViewController.h"


@interface DWVideoViewController() 
	- (void)displaySpinner:(BOOL)withInit forOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
@end


@implementation DWVideoViewController



#pragma mark -
#pragma mark View lifecycle


// Init and setup the view
//
- (id)initWithMediaURL:(NSString*)theURL {
	
	NSURL *url = [[NSURL alloc] initWithString:theURL];
	self = [super initWithContentURL:url];
	[url release];
    
	if (self) {
		[self.view setBackgroundColor:[UIColor blackColor]];
		
		[self displaySpinner:YES forOrientation:[DWGUIManager getCurrentOrientation]];
		
		//Listen for movie player notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:[self moviePlayer]
		 ];
	}
    
	return self;
}


// Allow all orientations
//
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


// Refits the image when the device is about to be rotated
//
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self displaySpinner:NO forOrientation:toInterfaceOrientation];
}


// Display the spinner in the middle of the screen 
//
- (void)displaySpinner:(BOOL)withInit forOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	UIActivityIndicatorView *spinner = nil;
	CGSize screenSize = [DWGUIManager currentScreenSize:toInterfaceOrientation];
	
	//Add a spinner to the center of the movie player view
	CGRect frame = CGRectMake((screenSize.width - VIDEO_VIEW_SPINNER_SIDE)/2,
							  (screenSize.height - VIDEO_VIEW_SPINNER_SIDE)/2 ,
							  VIDEO_VIEW_SPINNER_SIDE,VIDEO_VIEW_SPINNER_SIDE
							  );
	
	if(withInit) {
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		spinner.tag = 3;
		[spinner startAnimating];
		[self.view addSubview:spinner];
		[spinner release];
	}
	else {
		spinner = (UIActivityIndicatorView*)[self.view viewWithTag:3];
		spinner.frame = frame;
	}
	
}



#pragma mark -
#pragma mark Movie player notifications

// Receives notifications from the movie player. When the video has loaded
// i.e. loadState is 1 the spinner stops animating
//
- (void)moviePlayBackDidFinish:(NSNotification*)notification {
	if ([[self moviePlayer] loadState] == 1) {
		UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[self.view viewWithTag:3];
		[spinner stopAnimating];
	}
}



#pragma mark -
#pragma mark Memory Management


// The usual memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// The usual view did unload
//
- (void)viewDidUnload {
    [super viewDidUnload];
}


// The usual dealloc
//
- (void)dealloc {
    [super dealloc];
}


@end
