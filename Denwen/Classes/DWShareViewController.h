//
//  DWShareViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DWPlace.h"
#import "DWRequestsManager.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "FBConnect.h"
#import "MBProgressHUD.h"

#import "DWSession.h"


@protocol DWShareViewControllerDelegate;


@interface DWShareViewController : UIViewController <SA_OAuthTwitterEngineDelegate,SA_OAuthTwitterControllerDelegate,FBSessionDelegate,FBRequestDelegate> {
	UIView *sharingOptionsContainerView;
	UISwitch *twitterSwitch;
	UISwitch *facebookSwitch;
	UITextView *textView;
	UIBarButtonItem *doneButton;
	UIImageView *backgroundImageView;
	UINavigationBar *navigationBar;
	UILabel *hashedLink;
	
	SA_OAuthTwitterEngine *_twitterEngine;
	Facebook *_facebook;
	DWPlace *_place;
	
	BOOL _twitterRequestDone;
	BOOL _facebookRequestDone;
	
	MBProgressHUD *mbProgressIndicator;
	
	id <DWShareViewControllerDelegate> _delegate;
}

@property (nonatomic, retain) IBOutlet UIView *sharingOptionsContainerView;
@property (nonatomic, retain) IBOutlet UISwitch *twitterSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *facebookSwitch;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UILabel *hashedLink;


- (id)initWithDelegate:(id)delegate andPlace:(DWPlace*)place;


- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

- (IBAction)twitterSwitchValueChanged:(id)sender;
- (IBAction)facebookSwitchValueChanged:(id)sender;



@end


@protocol DWShareViewControllerDelegate
- (void)shareViewFinished:(NSString*)data sentTo:(NSInteger)sentTo;
- (void)shareViewCancelled;
@end
