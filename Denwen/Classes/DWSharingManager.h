//
//  DWSharingManager.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@class DWItem;
@protocol DWSharingManagerDelegate;

/**
 * Manage sharing via different modalities
 */
@interface DWSharingManager : NSObject<UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
    
    DWItem              *_item;
    UIViewController    *_baseController;
    
    BOOL                _waitingForAddress;
    NSInteger           _sharingType;
    NSInteger           _cancelButtonIndex;
    
    id<DWSharingManagerDelegate> _delegate;
}

/**
 * The item being shared
 */
@property (nonatomic,retain) DWItem *item;

/**
 * Base controller for presenting the UI elements
 */
@property (nonatomic,assign) UIViewController *baseController;

/**
 * DWSharingManagerDelegate
 */
@property (nonatomic,assign) id<DWSharingManagerDelegate> delegate;


/**
 * Share an item by first presenting a set of distribution options.
 * baseController is used to display the UI elements
 */
- (void)shareItem:(DWItem*)item 
    viaController:(UIViewController*)baseController;


@end


/**
 * Declarations for private methods
 */ 
@interface DWSharingManager(Private)
- (void)hideSpinner;
- (void)displaySpinner;
- (void)shareViaEmail;
- (void)shareViaSMS;
@end


/**
 * Fires events about the sharing lifecycle
 */
@protocol DWSharingManagerDelegate

/**
 * Fired when the sharing is cancelled or successfully finished
 */
- (void)sharingFinished;

@end
