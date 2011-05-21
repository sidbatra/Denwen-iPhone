//
//  DWSplashScreenViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DWSplashScreenViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView    *_scrollView;
    UIPageControl   *_pageControl;
    NSMutableArray  *_viewControllers;
    
    BOOL            _pageControlUsed;
}

/**
 * Mutable array for view controllers having the splash screen images
 */
@property (nonatomic, retain) NSMutableArray *viewControllers;

/**
 * IBOutlets
 */
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

/**
 * IBAction methods
 */
- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)changePage:(id)sender;

@end
