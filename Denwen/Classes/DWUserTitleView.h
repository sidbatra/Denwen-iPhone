//
//  DWUserTitleView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTitleView.h"


/**
 * Custom user title view for placeviewcontroller nav bar
 */
@interface DWUserTitleView : DWTitleView {
    
}


/**
 * Display users name and number of places followed
 */
- (void)showUserStateFor:(NSString*)userName andFollowingCount:(NSInteger)followingCount;

@end
