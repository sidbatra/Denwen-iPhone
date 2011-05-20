//
//  DWSharingManager.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@class DWItem;

/**
 * Manage sharing via different modalities
 */
@interface DWSharingManager : NSObject<UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
    
    UIViewController *_baseController;
}

/**
 * Shared sole instance of the class
 */
+ (DWSharingManager *)sharedDWSharingManager;

/**
 * Base controller for presenting the UI elements
 */
@property (nonatomic,assign) UIViewController *baseController;


/**
 * Share an item by first presenting a set of distribution options.
 * baseController is used to display the UI elements
 */
- (void)shareItem:(DWItem*)item 
    viaController:(UIViewController*)baseController;


@end
