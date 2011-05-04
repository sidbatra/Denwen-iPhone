//
//  DWUserTitleView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWUserTitleView.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWUserTitleView


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Update View Methods
//----------------------------------------------------------------------------------------------------
- (void)setSubTitleTextWithFollowersCount:(NSInteger)followingCount {
	NSString *text = nil;
	
	if(followingCount == 0) {
		text                    = @"No Places";
        underlayButton.enabled  = NO;
    }
	else if(followingCount == 1)
		text = [NSString stringWithFormat:@"Following %d place",followingCount];
	else
		text = [NSString stringWithFormat:@"Following %d places",followingCount];
	
    subtitleLabel.text = text;
}

//----------------------------------------------------------------------------------------------------
- (void)showUserStateFor:(NSString*)userName andFollowingCount:(NSInteger)followingCount {
    underlayButton.enabled      = YES;
    titleLabel.text             = userName;
    [self setSubTitleTextWithFollowersCount:followingCount];
}

@end
