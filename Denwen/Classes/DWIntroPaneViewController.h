//
//  DWIntroPaneViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Custom controller for having splash screen images
 */
@interface DWIntroPaneViewController : UIViewController {
    UIImageView *_imageView;
}

/**
 * Custom init to specify the page number for the image
 */
- (id)initWithPageNumber:(NSInteger)pageNumber;

/**
 * Image view for the splash screen image
 */
@property (nonatomic,retain) UIImageView *imageView;

@end