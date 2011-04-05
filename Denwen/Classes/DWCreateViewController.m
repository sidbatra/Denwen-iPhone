//
//  DWCreateViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWCreateViewController.h"

static NSString* const kTabTitle					= @"Create";
static NSString* const kImgTab						= @"profile.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWCreateViewController

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if (self) {		
		self.title						= kTabTitle;
		self.tabBarItem.image			= [UIImage imageNamed:kImgTab];
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
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
- (BOOL)isSelectedTab {
	return self.tabBarController.selectedViewController == self;
}


@end
