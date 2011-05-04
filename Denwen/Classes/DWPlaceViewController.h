//
//  DWPlaceViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"

@class DWFollowing;
@class DWPlaceTitleView;

/**
 * Place view with place info and all the items posted at
 * this place
 */
@interface DWPlaceViewController : DWItemFeedViewController<UIActionSheetDelegate> {
	DWPlace             *_place;
	DWFollowing         *_following;
    DWPlaceTitleView    *_placeTitleView;	
}

/**
 * The place obejct whose items and details are being displayed
 */
@property (nonatomic,retain) DWPlace *place;

/**
 * Following object representing the follower relationship between
 * the current user and the place being viwed
 */
@property (nonatomic,retain) DWFollowing *following;

/**
 * Subview for displaying follow button and following count
 */
@property (nonatomic,retain) DWPlaceTitleView *placeTitleView;

/**
 * Init with place and item feed delegate to receive navigation
 * events
 */
-(id)initWithPlace:(DWPlace*)thePlace 
	   andDelegate:(id)delegate;


@end
