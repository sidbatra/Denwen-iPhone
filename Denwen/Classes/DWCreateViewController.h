//
//  DWCreateViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Facilitates creation of items and places
 */
@interface DWCreateViewController : UIViewController {

}

@end

/**
 * Declarations for select private methods
 */
@interface DWCreateViewController(Private)

/**
 * Indicates if the create tab is currently selected
 */
- (BOOL)isTabSelected;

@end