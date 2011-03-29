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
													 name:kNImageLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageError:) 
													 name:kNImageError
												   object:nil];
	}
    
	return self;
}


// Setup UI elements and being downloading the image
//
- (void)viewDidLoad {
	[DWGUIManager showSpinnerInNav:self];
	[[DWRequestsManager sharedDWRequestsManager] requestImageAt:url 
														 ofType:kImgActualAttachment 
												 withResourceID:key];
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
	[[UIApplication sharedApplication] setStatusBarStyle:STATUS_BAR_STYLE];
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
	NSDictionary *info = [notification userInfo];
	
	NSInteger imageType		= [[info objectForKey:kKeyImageType] integerValue];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
		
	if(imageType == kImgActualAttachment && resourceID == key) {
		[(DWImageView*)self.view setupImageView:(UIImage*)[info objectForKey:kKeyImage]];
		[DWGUIManager hideSpinnnerInNav:self];
	}
}

- (void)imageError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	NSInteger imageType		= [[info objectForKey:kKeyImageType] integerValue];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
		
	if(imageType == kImgActualAttachment && resourceID == key) {
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
	[url release];
    [super dealloc];
}

@end
