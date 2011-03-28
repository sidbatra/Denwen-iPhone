//
//  DWPopularPlacesViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "DWPlaceListViewController.h"
#import "DWRequestsManager.h"


/**
 * Controller for the popular places view
 */
@interface DWPopularPlacesViewController : DWPlaceListViewController {
}

/**
 * Init with delegate to receive events about place selection
 */
- (id)initWithDelegate:(id)delegate;


@end