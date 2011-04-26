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
- (id)initWithFrame:(CGRect)frame 
           delegate:(id)delegate 
          titleMode:(NSInteger)titleViewMode 
      andButtonType:(NSInteger)buttonType {
    
    self =  [super initWithFrame:frame 
                        delegate:delegate 
                       titleMode:titleViewMode 
                   andButtonType:buttonType];
    
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
- (void)showProcessedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount {
    [self showLabelsAndStopSpinner];
    
    [self setSubTitleTextFor:placeName 
           andFollowersCount:followingCount];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Update View Methods
//----------------------------------------------------------------------------------------------------
- (void)showFollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount {
    titleLabel.text = @"Following";
    [self showProcessedStateFor:placeName 
              andFollowingCount:followingCount];
}

//----------------------------------------------------------------------------------------------------
- (void)showUnfollowedStateFor:(NSString*)placeName andFollowingCount:(NSInteger)followingCount {    
    titleLabel.text = @"Follow";
    [self showProcessedStateFor:placeName 
              andFollowingCount:followingCount];
}

//----------------------------------------------------------------------------------------------------
- (void)showProcessingState {
    [self hideLabelsAndStartSpinner];
}

@end
