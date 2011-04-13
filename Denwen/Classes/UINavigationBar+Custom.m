//
//  UINavigationBar+Custom.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "UINavigationBar+Custom.h"

static NSString* const kImgNavBarBg = @"nav_bar.png";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation UINavigationBar(Custom)

//----------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	
	
	[[UIImage imageNamed:kImgNavBarBg] drawAtPoint:CGPointMake(0,0)];
	
	CGContextRestoreGState(context);
}

@end