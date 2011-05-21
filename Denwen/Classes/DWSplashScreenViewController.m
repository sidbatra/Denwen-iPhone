//
//  DWSplashScreenViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSplashScreenViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"
#import "DWIntroPaneViewController.h"
#import "DWConstants.h"


static NSInteger kNumberOfPages = 4;


@interface DWSplashScreenViewController(PrivateMethods)
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSplashScreenViewController

@synthesize scrollView      = _scrollView;
@synthesize pageControl     = _pageControl;
@synthesize viewControllers = _viewControllers;

//----------------------------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    
    if(self) {

        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < kNumberOfPages; i++) 
            [controllers addObject:[NSNull null]];
        
        self.viewControllers = controllers;
        [controllers release];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
    
    self.scrollView         = nil;
    self.pageControl        = nil;
    self.viewControllers    = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize     = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, 
                                                 self.scrollView.frame.size.height);
    self.scrollView.scrollsToTop    = NO;
    
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}


//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private Methods

//----------------------------------------------------------------------------------------------------
- (void)loadScrollViewWithPage:(int)page {
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    DWIntroPaneViewController *controller = [self.viewControllers objectAtIndex:page];
    
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[DWIntroPaneViewController alloc] initWithPageNumber:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    if (controller.view.superview == nil) {        
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (_pageControlUsed)
        return;
	
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    

    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

//----------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)loginButtonClicked:(id)sender {
    DWLoginViewController *loginView    = [[[DWLoginViewController alloc] init] autorelease];
    
    [self.navigationController pushViewController:loginView
										 animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)signupButtonClicked:(id)sender {
    DWSignupViewController *signupView  = [[[DWSignupViewController alloc] init] autorelease];
    
    [self.navigationController pushViewController:signupView
										 animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)changePage:(id)sender {
    int page = self.pageControl.currentPage;
	
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    _pageControlUsed = YES;
}


@end
