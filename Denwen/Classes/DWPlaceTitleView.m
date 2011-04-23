//
//  DWPlaceTitleView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceTitleView.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceTitleView

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate andMode:(NSInteger)titleViewMode {
    self =  [super initWithFrame:frame andDelegate:delegate andMode:titleViewMode];
    
    if(self) {
        [self createSpinner];
    }
    
    return self;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private Methods
//----------------------------------------------------------------------------------------------------
- (void)createSpinner {
	spinner			= [[UIActivityIndicatorView alloc] 
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.frame	= CGRectMake(90,12,20,20);
    spinner.hidden  = YES;    
	
	[self addSubview:spinner];	
    [spinner release];
}

//----------------------------------------------------------------------------------------------------
- (void)showLabelsAndStopSpinner {
    titleLabel.hidden           = NO;
    subtitleLabel.hidden        = NO;
    underlayButton.enabled      = YES;
    
    [spinner stopAnimating];
    spinner.hidden              = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)hideLabelsAndStartSpinner {    
    titleLabel.hidden           = YES;
    subtitleLabel.hidden        = YES;
    underlayButton.enabled      = NO;    
    
    spinner.hidden              = NO;
    [spinner startAnimating];
}

//----------------------------------------------------------------------------------------------------
- (void)setSubTitleTextFor:(NSString*)placeName andFollowersCount:(NSInteger)followersCount {
	NSString *text = nil;
	
	if(followersCount == 0)
		text = [NSString stringWithFormat:@"%@",placeName];
	else if(followersCount == 1)
		text = [NSString stringWithFormat:@"%d is following",followersCount];
	else
		text = [NSString stringWithFormat:@"%d are following",followersCount];
	
    subtitleLabel.text = text;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Update View Methods
//----------------------------------------------------------------------------------------------------
- (void)showFollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount {
    [self showLabelsAndStopSpinner];
    
    titleLabel.text = @"Following";
    [self setSubTitleTextFor:placeName 
           andFollowersCount:followingCount];
}

//----------------------------------------------------------------------------------------------------
- (void)showUnfollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount {
    [self showLabelsAndStopSpinner];
    
    titleLabel.text = @"Follow";
    [self setSubTitleTextFor:placeName 
           andFollowersCount:followingCount];
}

//----------------------------------------------------------------------------------------------------
- (void)showProcessingState {
    [self hideLabelsAndStartSpinner];
    [spinner startAnimating];
}

@end
