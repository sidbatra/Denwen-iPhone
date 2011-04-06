//
//  DWCreateViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWPlacesSearchResultsViewController.h"

#import "KTTextView.h"

/**
 * Facilitates creation of items and places
 */
@interface DWCreateViewController : UIViewController {
	UIImageView				*_previewImageView;
	UIImageView				*_transImageView;
	UITextField				*_placeNameTextField;
	KTTextView				*_dataTextView;
	
	DWPlacesSearchResultsViewController *_searchResults;
}

/**
 * Table view controller for displaying results for a place name search
 */
@property (nonatomic,retain) DWPlacesSearchResultsViewController *searchResults;

/**
 * IBOutlet properties
 */

@property (nonatomic, retain) IBOutlet UIImageView *previewImageView;
@property (nonatomic, retain) IBOutlet UIImageView *transImageView;
@property (nonatomic, retain) IBOutlet UITextField *placeNameTextField;
@property (nonatomic, retain) IBOutlet KTTextView *dataTextView;

/**
 * IBActions
 */
- (IBAction)cancelButtonClicked:(id)sender;


@end


/**
 * Declarations for select private methods
 */
@interface DWCreateViewController(Private)

/**
 * Indicates if the create tab is currently selected
 */
- (BOOL)isSelectedTab;

@end