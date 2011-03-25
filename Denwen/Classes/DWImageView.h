//
//  DWImageView.h
//  Denwen
//
//  Created by Siddharth Batra on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Renders a UIScrollView for the manipulation of images - zooming, rotations, centering etc
//

#import <UIKit/UIKit.h>

#import "DWGUIManager.h"
#import "Constants.h"


@interface DWImageView : UIScrollView <UIScrollViewDelegate> {
	UIImageView *imageView;
}

@property (readonly) UIImageView* imageView;

-(void)setupImageView:(UIImage*)image;
-(void)fitImage:(UIInterfaceOrientation)toInterfaceOrientation;

@end
