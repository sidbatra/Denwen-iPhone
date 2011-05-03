//
//  DWNewUserPhotoQueueItem.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWCreationQueueItem.h"

/**
 * Queue item for creating a new user profile picture
 */
@interface DWNewUserPhotoQueueItem : DWCreationQueueItem {
    UIImage         *_image;
    UIImage         *_imageClone;
    NSInteger       _userID;
}

/**
 * The profile picture
 */
@property (nonatomic,retain) UIImage *image;


/**
 * The profile picture clone for passing with
 * the notifications
 */
@property (nonatomic,retain) UIImage *imageClone;


/**
 * Start the request to update the user image
 */
- (void)updatePhotoForUserWithID:(NSInteger)userID
                         toImage:(UIImage*)theImage;

@end
