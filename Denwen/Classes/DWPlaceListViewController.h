//
//  DWPlaceListViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWTableViewController.h"
#import "DWPlaceViewController.h"
#import "DWPlacesManager.h"


@protocol DWPlaceListViewControllerDelegate;

/**
 * Base class for displaying a list of places
 */
@interface DWPlaceListViewController : DWTableViewController {
	DWPlacesManager     *_placeManager;
	
	id <DWPlaceListViewControllerDelegate>	_delegate;
}

/**
 * Manages retreival and creation of DWPlace objects
 */
@property (nonatomic,retain) DWPlacesManager *placeManager;


/**
 * Init with 
 * capacity (different types of places needed by the view)
 * delegate to receive events when a place is selected
 */
- (id)initWithCapacity:(NSInteger)capacity 
           andDelegate:(id)delegate;

/**
 * Fired when the view is selected in a segmented controller setup
 */
- (void)viewIsSelected;

/**
 * Fired when the view is deselected in a segmented controller setup
 */
- (void)viewIsDeselected;

@end


/**
 * Delegate protocol to receive updates from all children of place list view
 */
@protocol DWPlaceListViewControllerDelegate

/**
 * Fired when a place cell is selected
 */
- (void)placeSelected:(DWPlace*)place;

@end

