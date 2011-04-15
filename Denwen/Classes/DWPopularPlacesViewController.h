//
//  DWPopularPlacesViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWPlaceListViewController.h"

/**
 * Display popular places 
 */
@interface DWPopularPlacesViewController : DWPlaceListViewController {
}

/**
 * Init with delegate to receive events about place selection
 */
- (id)initWithDelegate:(id)delegate;


@end