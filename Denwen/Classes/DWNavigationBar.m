//
//  DWNavigationBar.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNavigationBar.h"

static NSString* const kImgNavBarBg = @"nav_bar.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNavigationBar

//----------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	
	
	[[UIImage imageNamed:kImgNavBarBg] drawAtPoint:CGPointMake(0,0)];
	
	CGContextRestoreGState(context);
}


@end
