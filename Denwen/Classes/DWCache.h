//
//  DWCache.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWConstants.h"

@interface DWCache : NSObject {
}

+(void)initCache;
+(void)clearCache;
+(NSMutableData*)fetchDataForKey:(NSString*)key;
+(void)setDataForKey:(NSString*)key withData:(NSMutableData*)data;
+(void)handleError:(NSError*)error;

@end
