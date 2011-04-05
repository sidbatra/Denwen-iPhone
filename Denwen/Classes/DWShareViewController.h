//
//  DWShareViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWPlace.h"

#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "FBConnect.h"
#import "MBProgressHUD.h"

@protocol DWShareViewControllerDelegate;

/**
 * View for sharing a place wherein data is written and services to post to are choosen
 */
@interface DWShareViewController : UIViewController <SA_OAuthTwitterEngineDelegate,SA_OAuthTwitterControllerDelegate,FBSessionDelegate,FBRequestDelegate> {
	DWPlace					*_place;
	
	SA_OAuthTwitterEngine	*_twitterEngine;
	Facebook				*_facebook;
	
	UIView					*_sharingOptionsContainerView;
	UISwitch				*_twitterSwitch;
	UISwitch				*_facebookSwitch;
	UITextView				*_textView;
	UIBarButtonItem			*_doneButton;
	UIImageView				*_backgroundImageView;
	UINavigationBar			*_navigationBar;
	UILabel					*_hashedLink;
	
	BOOL					_twitterRequestDone;
	BOOL					_facebookRequestDone;
	
	MBProgressHUD			*_mbProgressIndicator;
	
	id <DWShareViewControllerDelegate> _delegate;
}

/**
 * Place object for the place being shared
 */
@property (nonatomic,retain) DWPlace *place;

/**
 * Object of third party service to perform twitter connect
 */
@property (nonatomic,retain) SA_OAuthTwitterEngine *twitterEngine;

/**
 * Object of third party service to perform facebook connect
 */
@property (nonatomic,retain) Facebook *facebook;

/**
 * Progress indicator subview
 */
@property (nonatomic,retain) MBProgressHUD *mbProgressIndicator;


/**
 * IBOutlet properties
 */

@property (nonatomic, retain) IBOutlet UIView *sharingOptionsContainerView;
@property (nonatomic, retain) IBOutlet UISwitch *twitterSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *facebookSwitch;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UILabel *hashedLink;


/**
 * Init with place and delegate to receive events when sharing is canceled
 * or finished
 */
- (id)initWithPlace:(DWPlace*)thePlace
		andDelegate:(id)delegate;


/**
 * IBAction events
 */
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

- (IBAction)twitterSwitchValueChanged:(id)sender;
- (IBAction)facebookSwitchValueChanged:(id)sender;

@end


/**
 * Protocol to send events about sharing a place
 */
@protocol DWShareViewControllerDelegate

/**
 * Fired when sharing is finished and sends the data posted
 * and the services it was posted to
 */
- (void)shareViewFinished:(NSString*)data
				   sentTo:(NSInteger)sentTo;

/**
 * Fired when sharing is cancelled
 */
- (void)shareViewCancelled;
@end
