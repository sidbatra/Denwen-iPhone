//
//  DWImageHelper.m
//  Denwen
//
//  Created by Siddharth Batra on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWImageHelper.h"


@implementation DWImageHelper


// Resizes the given image to the given size
//
+ (UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

@end
