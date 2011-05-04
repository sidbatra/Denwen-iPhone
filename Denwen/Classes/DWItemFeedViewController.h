//
//  DWItemFeedViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWTableViewController.h"
#import "DWItemsManager.h"
#import "DWItemFeedCell.h"

@protocol DWItemFeedViewControllerDelegate;

/**
 * Base class for displaying a feed of items
 */
@interface DWItemFeedViewController : DWTableViewController<DWItemFeedCellDelegate,UIActionSheetDelegate> {
	
	DWItemsManager  *_itemManager;
	id <DWItemFeedViewControllerDelegate>	_delegate;
}

/**
 * Manages retreival and creation of items
 */
@property (nonatomic,retain) DWItemsManager *itemManager;


/**
 * Init with delegate to receive updates about selection of navigation items
 */
- (id)initWithDelegate:(id)delegate;

/**
 * Add the given new item at the index from the top of the table view
 */
- (void)addNewItem:(DWItem *)item 
		   atIndex:(NSInteger)index;

@end


/**
 * Delegate protocol to receive events when navigation elements are selected
 */
@protocol DWItemFeedViewControllerDelegate

/**
 * Fired when a place is selected from it's name or photo
 */
- (void)placeSelected:(DWPlace*)place;

/**
 * Fired when a user is selected from it's name or photo
 */
- (void)userSelected:(DWUser*)user;

/** 
 * Fired when the custom tab bar controller is requested for showing the 
 * media picker to change profile picture
 */
- (UIViewController*)requestCustomTabBarController;

@end

