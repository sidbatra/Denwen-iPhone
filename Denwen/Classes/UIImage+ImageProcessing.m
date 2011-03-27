//
//  UIImage+ImageProcessing.m
//  Copyright 2011 Denwen. All rights reserved.
//


#import "UIImage+ImageProcessing.h"

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation UIImage (ImageProcessing)


//----------------------------------------------------------------------------------------------------
- (UIImage *)resizeTo:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}


@end
