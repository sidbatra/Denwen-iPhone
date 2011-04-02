//
//  DWFollowedItemsViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"

/**
 * Feed view
 */
@interface DWFollowedItemsViewController : DWItemFeedViewController {
}

/**
 * Init with delegate to receive events when navigation
 * elements are 
 */
- (id)initWithDelegate:(id)delegate;

/**
 * Scroll the table view to the top
 */
- (void)scrollToTop;

/**
 * Refresh the UI when the new items have been read
 */
- (void)followedItemsRead;

@end