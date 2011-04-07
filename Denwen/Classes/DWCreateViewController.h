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
@interface DWCreateViewController : UIViewController<DWPlacesSearchResultsViewControllerDelegate> {
	UIImageView				*_previewImageView;
	UIImageView				*_transImageView;
	UITextField				*_placeNameTextField;
	KTTextView				*_dataTextView;
	UIButton				*_mapButton;
	
	BOOL					_newPlaceMode;
	
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
@property (nonatomic, retain) IBOutlet UIButton *mapButton;

/**
 * IBActions
 */
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)placeNameTextFieldEditingChanged:(id)sender;


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