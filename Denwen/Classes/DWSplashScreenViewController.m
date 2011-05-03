//
//  DWSplashScreenViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSplashScreenViewController.h"
#import "DWLoginViewController.h"
#import "DWSignupViewController.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSplashScreenViewController

//----------------------------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    
    if(self) {
        
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
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)loginButtonClicked:(id)sender {
    DWLoginViewController *loginView    = [[[DWLoginViewController alloc] init] autorelease];
    
    [self presentModalViewController:loginView
                            animated:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)signupButtonClicked:(id)sender {
    DWSignupViewController *signupView  = [[[DWSignupViewController alloc] init] autorelease];
    
    [self presentModalViewController:signupView
                            animated:YES];
}


@end
