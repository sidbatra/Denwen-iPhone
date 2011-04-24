//
//  DWTouchesManager.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWTouch;

/**
 * Manages a group of touches and abstracts their memory 
 * management and retrieval
 */
@interface DWTouchesManager : NSObject {
    NSMutableArray  *_touches;
}

/**
 * Retrieve the total number of touches
 */
- (NSInteger)totalTouches;

/**
 * Retrieve the touch at the given index
 */
- (DWTouch*)getTouch:(NSInteger)index;

/**
 * Add the given touch at the given index
 */
- (void)addTouch:(DWTouch*)touch
		atIndex:(NSInteger)index;

/**
 * Populate the array of touches from the given JSON
 * clearStatus indicates whether the touches are appended
 * or the old ones are removed
 */
- (void)populateTouches:(NSArray*)touches 
        withClearStatus:(BOOL)clearStatus;

/**
 * Delete all touches from the array
 */
- (void)clearAllTouches;


@end
