//
//  DWShareItemViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWFacebookConnect.h"

@class DWItem;
@protocol DWShareItemViewControllerDelegate;

/**
 * Enum sharing destinations
 */
enum DWSharingDestination {
    kSharingDestinationFacebook,
    kSharingDestinationTwitter
};

typedef enum DWSharingDestination DWSharingDestination;

/**
 * View for sharing items to Facebook and Twiiter
 */
@interface DWShareItemViewController : UIViewController<DWFacebookConnectDelegate> {
    DWItem                  *_item;
    NSString                *_itemURL;
    NSString                *_sharingText;
    DWSharingDestination    _sharingDestination;
    
    DWFacebookConnect       *_facebookConnect;
    
	UIImageView             *_previewImageView;
	UIImageView             *_transImageView;
	UITextView              *_dataTextView;
	UIButton                *_cancelButton;
	UIButton                *_doneButton;
	UILabel                 *_coverLabel;
    
    id<DWShareItemViewControllerDelegate>   _delegate;
}

/**
 * The item being shared
 */
@property (nonatomic,retain) DWItem *item;

/**
 * URL for the item being shared
 */
@property (nonatomic,copy) NSString *itemURL;

/**
 * Text initially displayed in the text view
 */
@property (nonatomic,copy) NSString *sharingText;

/**
 * Instance of the facebook connect wrapper
 */
@property (nonatomic,retain) DWFacebookConnect *facebookConnect;

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
 * Prepare UI and flow for sharing to facebook
 */
- (void)prepareForFacebookWithText:(NSString*)text 
                            andURL:(NSString*)url;

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