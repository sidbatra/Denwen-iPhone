//
//  DWUserProfileTitleView.m
//  Denwen
//
//  Created by Deepak Rao on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUserProfileTitleView.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWUserProfileTitleView

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame 
           delegate:(id)delegate 
          titleMode:(NSInteger)titleViewMode 
      andButtonType:(NSInteger)buttonType {
    
    self =  [super initWithFrame:frame 
                        delegate:delegate 
                       titleMode:titleViewMode 
                   andButtonType:buttonType];
    
    if(self) 
        [self createSpinner];
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)showUserStateFor:(NSString*)userName andIsCurrentUser:(BOOL)isCurrentUser {
    [self showNormalState];
    
    if (isCurrentUser) {
        standaloneTitleLabel.text               = @"Profile Picture";
        underlayButton.enabled                  = YES;
        underlayButton.userInteractionEnabled   = NO;        
    }
    else {
        standaloneTitleLabel.text               = userName;
        underlayButton.hidden                   = YES;
    }
}

//----------------------------------------------------------------------------------------------------
- (void)showProcessingState {
    standaloneTitleLabel.hidden     = YES;
    spinner.hidden                  = NO;
    [spinner startAnimating];
}

//----------------------------------------------------------------------------------------------------
- (void)showNormalState {
    [spinner stopAnimating];
    spinner.hidden                  = YES;
    standaloneTitleLabel.hidden     = NO;
}

@end
