//
//  DWShareItemViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWItem;
@protocol DWShareItemViewControllerDelegate;

/**
 * View for sharing items to Facebook and Twiiter
 */
@interface DWShareItemViewController : UIViewController {
    DWItem          *_item;
    
	UIImageView		*_previewImageView;
	UIImageView     *_transImageView;
	UITextView      *_dataTextView;
	UIButton		*_cancelButton;
	UIButton		*_doneButton;
	UILabel			*_coverLabel;
    
    id<DWShareItemViewControllerDelegate>   _delegate;
}

/**
 * The item being shared
 */
@property (nonatomic,retain) DWItem *item;

/**
 * Delegate to receive events about the sharing lifecycle
 */
@property (nonatomic,assign) id<DWShareItemViewControllerDelegate> delegate;

/**
 * IBOutlet properties
 */
@property (nonatomic,retain) IBOutlet UIImageView *previewImageView;
@property (nonatomic,retain) IBOutlet UIImageView *transImageView;
@property (nonatomic,retain) IBOutlet UITextView *dataTextView;
@property (nonatomic,retain) IBOutlet UIButton *cancelButton;
@property (nonatomic,retain) IBOutlet UIButton *doneButton;
@property (nonatomic,retain) IBOutlet UILabel *coverLabel;


/**
 * Init with the item to be shared
 */
- (id)initWithItem:(DWItem*)theItem;

/**
 * IBActions
 */
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end

/**
 * Delegate to send events about the item sharing lifecycle
 */
@protocol DWShareItemViewControllerDelegate
- (void)sharingCancelled;
- (void)sharingFinishedWithText:(NSString*)text;
@end