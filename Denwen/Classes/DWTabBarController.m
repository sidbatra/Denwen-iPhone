    //
//  DWTabBarController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTabBarController.h"
#import "DWTabBar.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTabBarController

@synthesize tabBar				= _tabBar;
@synthesize subControllers		= _subControllers;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)theDelegate 
	   withTabBarFrame:(CGRect)tabBarFrame
		 andTabBarInfo:(NSArray*)tabBarInfo {
	
	self = [super init];
	
	if(self) {
		
		_delegate	= theDelegate;
		self.tabBar = [[[DWTabBar alloc] initWithFrame:tabBarFrame
											  withInfo:tabBarInfo 
										  andDelegate:self] autorelease];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	self.tabBar			= nil;
	self.subControllers	= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
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
- (void)removeViewAtIndex:(NSInteger)index {
	[((UIViewController*)[self.subControllers objectAtIndex:index]).view removeFromSuperview];
}

//----------------------------------------------------------------------------------------------------
- (void)addViewAtIndex:(NSInteger)index {
	
	UIViewController *controller = [self.subControllers objectAtIndex:index];
	controller.view.frame = CGRectMake(0,0,
									   self.view.frame.size.width,
									   self.view.frame.size.height-self.tabBar.frame.size.height);
	
	[self.view insertSubview:controller.view belowSubview:self.tabBar];
}

//----------------------------------------------------------------------------------------------------
- (UIViewController*)getSelectedController {
	return [self.subControllers objectAtIndex:self.tabBar.selectedIndex];
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

@end
