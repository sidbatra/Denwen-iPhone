    //
//  DWTabBarController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTabBarController.h"
#import "DWTabBar.h"

#define kApplicationFrame	CGRectMake(0,20,320,460)
#define kFullScreenFrame	CGRectMake(0,0,320,480)
#define kResetFrameDelay    0.3

static NSString* const kImgTopShadow        = @"shadow_top.png";
static NSString* const kImgBottomShadow     = @"shadow_bottom.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTabBarController

@synthesize tabBar				= _tabBar;
@synthesize topShadowView       = _topShadowView;
@synthesize bottomShadowView    = _bottomShadowView;
@synthesize subControllers		= _subControllers;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate 
	   withTabBarFrame:(CGRect)tabBarFrame
		 andTabBarInfo:(NSArray*)tabBarInfo {
	
	self = [super init];
	
	if(self) {
		
        _delegate                       = theDelegate;
		self.tabBar                     = [[[DWTabBar alloc] initWithFrame:tabBarFrame
                                                                  withInfo:tabBarInfo 
                                                               andDelegate:self] autorelease];
        
        self.topShadowView              = [[[UIImageView alloc] initWithImage:
                                            [UIImage imageNamed:kImgTopShadow]] autorelease];
        self.topShadowView.frame        = CGRectMake(0,44,320,5);
        
        self.bottomShadowView           = [[[UIImageView alloc] initWithImage:
                                            [UIImage imageNamed:kImgBottomShadow]] autorelease];
        self.bottomShadowView.frame     = CGRectMake(0,self.tabBar.frame.origin.y-5,320,5);
        
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(playbackDidFinish:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.tabBar             = nil;
    self.topShadowView      = nil;
    self.bottomShadowView   = nil;
	self.subControllers     = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self.view addSubview:self.topShadowView];
    [self.view addSubview:self.bottomShadowView];
	[self.view addSubview:self.tabBar];
	[self addViewAtIndex:self.tabBar.selectedIndex];
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
- (void)resetFrame {
	self.view.frame = kApplicationFrame;
}

//----------------------------------------------------------------------------------------------------
- (void)removeViewAtIndex:(NSInteger)index {
	[((UIViewController*)[self.subControllers objectAtIndex:index]).view removeFromSuperview];
}

//----------------------------------------------------------------------------------------------------
- (void)addViewAtIndex:(NSInteger)index {
	
	UIViewController *controller = [self.subControllers objectAtIndex:index];

	controller.view.frame = CGRectMake(0,0,
									   self.view.frame.size.width,
									   460-self.tabBar.frame.size.height);
	
	[self.view insertSubview:controller.view 
                belowSubview:self.topShadowView];
}

//----------------------------------------------------------------------------------------------------
- (UIViewController*)getSelectedController {
	return [self.subControllers objectAtIndex:self.tabBar.selectedIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)enableFullScreen {
	self.tabBar.hidden                      = YES;
    self.bottomShadowView.hidden            = YES;
    
    [self getSelectedController].view.frame = kFullScreenFrame;
}

//----------------------------------------------------------------------------------------------------
- (void)disableFullScreen {
	self.tabBar.hidden                      = NO;
    self.bottomShadowView.hidden            = NO;
    
    [self getSelectedController].view.frame = CGRectMake(0,0,
                                                         self.view.frame.size.width,
                                                         460-self.tabBar.frame.size.height);
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTabBarDelegate

//----------------------------------------------------------------------------------------------------
- (void)selectedTabWithSpecialTab:(BOOL)isSpecial
					 modifiedFrom:(NSInteger)oldSelectedIndex 
							   to:(NSInteger)newSelectedIndex {
	
	if(!isSpecial) {
		[self removeViewAtIndex:oldSelectedIndex];
		[self addViewAtIndex:newSelectedIndex];
	}
	
	[_delegate selectedTabModifiedFrom:oldSelectedIndex
									to:newSelectedIndex];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)playbackDidFinish:(NSNotification*)notification {
	[self performSelector:@selector(resetFrame)
			   withObject:nil 
			   afterDelay:kResetFrameDelay];
}


@end
