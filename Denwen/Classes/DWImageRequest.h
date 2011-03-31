//
//  DWImageRequest.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWRequest.h"

/**
 * Handles image download requests
 */
@interface DWImageRequest : DWRequest {
}

/**
 * Use the requestWithRequestURL in the parent and customize cache settings
 */
+ (id)requestWithRequestURL:(NSString*)requestURL 
				 resourceID:(NSInteger)theResourceID
		successNotification:(NSString*)theSuccessNotification
		  errorNotification:(NSString*)theErrorNotification;

@end
