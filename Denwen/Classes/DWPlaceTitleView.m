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
- (void)setSubTitleTextFor:(NSString*)placeName
         andFollowersCount:(NSInteger)followersCount
                asFollower:(BOOL)isFollower {
    
	NSString *text = nil;
	
	if(followersCount == 0)
		text = [NSString stringWithFormat:@"..."];
	else if(followersCount == 1 && isFollower)
		text = [NSString stringWithFormat:@"You are following"];
    else if(followersCount == 1)
        text = [NSString stringWithFormat:@"1 follower"];
    else if(isFollower)
        text = [NSString stringWithFormat:@"You and %d following",followersCount-1];
	else
		text = [NSString stringWithFormat:@"%d are following",followersCount];
	
    subtitleLabel.text = text;
}

//----------------------------------------------------------------------------------------------------
- (void)showProcessedStateFor:(NSString*)placeName 
            andFollowingCount:(NSInteger)followingCount
                   asFollower:(BOOL)isFollower {
    
    [self showLabelsAndStopSpinner];
    
    [self setSubTitleTextFor:placeName 
           andFollowersCount:followingCount
                  asFollower:isFollower];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Update View Methods
//----------------------------------------------------------------------------------------------------
- (void)showFollowedStateFor:(NSString*)placeName
           andFollowingCount:(NSInteger)followingCount {
    
    titleLabel.text = [NSString stringWithFormat:@"%@",placeName];
    
    [self showProcessedStateFor:placeName 
              andFollowingCount:followingCount
                     asFollower:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)showUnfollowedStateFor:(NSString*)placeName
             andFollowingCount:(NSInteger)followingCount {    
    
    titleLabel.text = [NSString stringWithFormat:@"Follow %@",placeName];
    
    [self showProcessedStateFor:placeName 
              andFollowingCount:followingCount
                     asFollower:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)showProcessingState {
    [self hideLabelsAndStartSpinner];
}

@end
