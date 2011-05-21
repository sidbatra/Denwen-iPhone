//
//  DWIntroPaneViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWIntroPaneViewController.h"

static NSString* const kImgSplashScreenPrefix = @"intro_pane";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWIntroPaneViewController

@synthesize imageView = _imageView;

//----------------------------------------------------------------------------------------------------
- (id)initWithPageNumber:(NSInteger)pageNumber {
    self = [super init];
    
    if (self) {
        self.imageView = [[[UIImageView alloc] initWithImage:
                           [UIImage imageNamed:[NSString stringWithFormat:@"%@_%d.png",kImgSplashScreenPrefix,pageNumber+1]]] 
                          autorelease];
        
        self.imageView.frame = CGRectMake(0, 0, 320, 295);
    }
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    self.imageView  = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    self.view.frame = self.imageView.frame;
    [self.view addSubview:self.imageView];
    
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

@end
