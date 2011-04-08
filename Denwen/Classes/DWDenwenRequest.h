//
//  DWDenwenRequest.h
//  Copyright 2011 Denwen. All rights reserved.
//	

#import <Foundation/Foundation.h>

#import "DWRequest.h"

/**
 * Handles requests made to the Denwen server
 */
@interface DWDenwenRequest : DWRequest {
}

/**
 * Generates a timestamp based unique resourceID
 */
- (void)generateResourceID;

@end