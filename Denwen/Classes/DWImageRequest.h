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
	NSInteger _ownerID;
	NSInteger _imageType;
}

/**
 * Unique identifier for the object that owns the image
 */
@property (nonatomic,assign) NSInteger ownerID;

/**
 * Classification of the image type
 */
@property (nonatomic,assign) NSInteger imageType;


/**
 * Use the requestWithRequestURL method in the parent class
 * and set the given imageType and ownerID via properties
 */
+ (id)requestWithRequestURL:(NSString*)requestURL 
					ownerID:(NSInteger)theOwnerID
				  imageType:(NSInteger)theImageType;

@end
