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
		key	= [[NSDate date] timeIntervalSince1970];

		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageLoaded:) 
													 name:kNImgActualUserImageLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageError:) 
													 name:kNImgActualUserImageError
												   object:nil];
	}
    
	return self;
}


// Setup UI elements and being downloading the image
//
- (void)viewDidLoad {
	[DWGUIManager showSpinnerInNav:self];
	[[DWRequestsManager sharedDWRequestsManager] getImageAt:url 
											 withResourceID:key
										successNotification:kNImgActualUserImageLoaded
										  errorNotification:kNImgActualUserImageError];
	 
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
	[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
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


- (void)imageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
		
	if(resourceID == key) {
		[(DWImageView*)self.view setupImageView:(UIImage*)[info objectForKey:kKeyImage]];
		[DWGUIManager hideSpinnnerInNav:self];
	}
}

- (void)imageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
		
	if(resourceID == key) {
		[DWGUIManager hideSpinnnerInNav:self];
	}
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[url release];
    [super dealloc];
}

@end
