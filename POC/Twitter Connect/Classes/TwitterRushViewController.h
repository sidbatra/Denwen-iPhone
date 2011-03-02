//
//  TwitterRushViewController.h
//  TwitterRush

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@interface TwitterRushViewController : UIViewController <UITextFieldDelegate, SA_OAuthTwitterControllerDelegate>
{ 
	IBOutlet UITextField *tweetTextField;
	
	SA_OAuthTwitterEngine				*_engine;	
}

@property(nonatomic, retain) IBOutlet UITextField *tweetTextField;

-(IBAction)updateTwitter:(id)sender; 

@end

