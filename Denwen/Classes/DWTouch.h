//
//  DWTouch.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWAttachment;
@class DWUser;

/**
 * Touch class represents a Touch entity
 * created by a user on someone else's item
 * (Represents Touch table in the database)
 */
@interface DWTouch : NSObject {
    NSInteger           _databaseID;
    NSString*           _itemData;
    NSString*           _placeName;
    
    DWAttachment*       _attachment;
    DWUser*             _user;
}

/**
 * DatabaseID for the touch object
 */
@property (nonatomic,readonly) NSInteger databaseID;

/**
 * Data of the item touched
 */
@property (nonatomic,copy) NSString* itemData;

/**
 * Name of the place where the touched item was posted
 */
@property (nonatomic,copy) NSString* placeName;

/**
 * Attachment of the item touched
 */
@property (nonatomic,retain) DWAttachment* attachment;

/**
 * User who created the touch
 */
@property (nonatomic,retain) DWUser* user;


/**
 * Starts downloading images needed to display the touch
 */
- (void)startDownloadingImages;

/**
 * Populate the touch via the given JSON dictionary
 */
- (void)populate:(NSDictionary*)touch;

/**
 * Display text used to display the touch
 */
- (NSString*)displayText;

@end
