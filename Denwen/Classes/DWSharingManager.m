//
//  DWSharingManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSharingManager.h"
#import "DWItem.h"
#import "DWSession.h"

#import "SynthesizeSingleton.h"

#define kShareCancelTitle       @"Cancel"
#define kShareButtonTitles      @"Facebook",@"Twitter",@"Email",@"SMS",nil
#define kShareFBIndex           0
#define kShareTWIndex           1
#define kShareEMIndex           2
#define kShareSMIndex           3



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSharingManager

@synthesize baseController  = _baseController;

SYNTHESIZE_SINGLETON_FOR_CLASS(DWSharingManager);

//----------------------------------------------------------------------------------------------------
- (void)shareItem:(DWItem*)item 
    viaController:(UIViewController*)baseController {
    
    
    self.baseController = baseController;
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:kShareCancelTitle
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:kShareButtonTitles];
    [actionSheet showInView:self.baseController.view];
    [actionSheet release];    
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIActionSheet Delegate

//----------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
    
    if(buttonIndex == kShareFBIndex) {
        NSLog(@"facebook");
    }
    else if(buttonIndex == kShareTWIndex) {
        NSLog(@"twitter"); 
    }
    else if(buttonIndex == kShareEMIndex) {
        MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
        
        mailView.mailComposeDelegate = self;
        
        [mailView setSubject:@"Well hellooo"];    
        [mailView setMessageBody:@"hi there waldo"
                          isHTML:YES];
        
        [self.baseController presentModalViewController:mailView
                                               animated:YES];
    }
    else if(buttonIndex == kShareSMIndex) {
        NSLog(@"sms");
    }
    
}

@end
