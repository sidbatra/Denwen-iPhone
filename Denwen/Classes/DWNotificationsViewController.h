//
//  DWNotificationsViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWTableViewController.h"

@protocol DWItemFeedViewControllerDelegate;
@class DWTouchesManager;

/**
 * Display notifications for the current user - mainly touches
 * on their items
 */
@interface DWNotificationsViewController : DWTableViewController {
    DWTouchesManager    *_touchesManager;
    
    id<DWItemFeedViewControllerDelegate>    _delegate;
}

/**
 * Abstracts retrieval and population of touches
 */
@property (nonatomic,retain) DWTouchesManager *touchesManager;


/**
 * Init with delegate to receive events when a user is selected
 */
- (id)initWithDelegate:(id)delegate;

@end

