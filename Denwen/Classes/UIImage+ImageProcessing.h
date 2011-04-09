//
//  UIImage+ImageProcessing.h
//  Copyright 2011 Denwen. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 * Extension of UIImage to support image processing utilities like 
 * resizing
 */
@interface UIImage (ImageProcessing)

/**
 * Resize the image to the given size and return an autoreleased image
 */
- (UIImage *)resizeTo:(CGSize)newSize;

/**
 * Rotate the image to the given orientation
 */
-(UIImage*)rotateTo:(UIImageOrientation)orient;

@end
