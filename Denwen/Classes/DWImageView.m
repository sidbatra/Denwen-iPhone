//
//  DWImageView.m
//  Denwen
//
//  Created by Siddharth Batra on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DWImageView.h"


@implementation DWImageView

@synthesize imageView;


#pragma mark -
#pragma mark ImageView Methods


//Override layoutSubviews to center the image when zoomed
//
- (void)layoutSubviews {
	
	CGRect frameToCenter = imageView.frame;
	CGSize screenSize = [DWGUIManager currentScreenSize];
	float screenWidth = screenSize.width;
	float screenHeight = screenSize.height - 50;
	
	// center horizontally
	if (frameToCenter.size.width < screenWidth)
		frameToCenter.origin.x = (screenWidth - frameToCenter.size.width) / 2;
	else
		frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < screenHeight)
        frameToCenter.origin.y = (screenHeight - frameToCenter.size.height) / 2;
    else
		frameToCenter.origin.y = 0;
	
	imageView.frame = frameToCenter;
}


//Creates an image from the raw imageData, puts it into an imageView and 
//and makes the imageView a subview of itself
//
- (void)setupImageView:(NSMutableData*)imageData {
	
	UIImage *image = [[UIImage alloc] initWithData:imageData];
	imageView = [[UIImageView alloc] initWithImage:image];
	[image release];

	[self addSubview:imageView];
	[self fitImage:[DWGUIManager getCurrentOrientation]];
	[self layoutSubviews];
	[imageView release];
}


// Fits the image perfectly to the available screen real estate
//
- (void)fitImage:(UIInterfaceOrientation)toInterfaceOrientation {
	
	[imageView setTransform: CGAffineTransformIdentity];
	
	
	CGSize screenSize = [DWGUIManager currentScreenSize:toInterfaceOrientation];
	float screenWidth = screenSize.width;
	float screenHeight = screenSize.height;
	
	//Resize image while maintaing aspect ratio and center image
	int finalWidth = -1;
	int finalHeight = -1;
	float imageWidth = imageView.image.size.width;
	float imageHeight = imageView.image.size.height;
	float screenRatio = screenWidth / screenHeight;
	float imageRatio = imageWidth / imageHeight;
	
	if(imageRatio <= screenRatio) {
		finalHeight = MIN(screenHeight,imageHeight);
		finalWidth = (finalHeight / imageHeight) * imageWidth;
	}
	else {
		finalWidth = MIN(screenWidth,imageWidth);
		finalHeight = (finalWidth / imageWidth) * imageHeight;
	}
	
	imageView.frame = CGRectMake(
								 (screenWidth - finalWidth)/2,
								 (screenHeight - finalHeight)/2,
								 finalWidth,
								 finalHeight
								 );
	
	self.contentSize = imageView.frame.size;
}


#pragma mark -
#pragma mark Memory management


// The usual cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
