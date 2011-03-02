//
//  DWCache.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWCache.h"
//#import "GAnalytics.h"

static NSString* cachePath = nil; //Path of the directory where the cache is stored
static NSError* error = nil; //Error object used as a reference during file operations

@implementation DWCache


// Create the local cache directory if it doesn't exist
//
+(void)initCache {
	
	// Create path to cache directory inside the application's Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	if(cachePath)
		[cachePath release];
	
    cachePath = [[NSString alloc] initWithFormat:@"%@/%@",[paths objectAtIndex:0],@"GCache"];
	
	// Check for existence of cache directory
	if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		return;
	}
	
	// Create a new cache directory
	if (![[NSFileManager defaultManager] createDirectoryAtPath:cachePath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		[DWCache handleError:error];		
	}		
}


// Delete the cache directory
//
+(void)clearCache {
	
	if (![[NSFileManager defaultManager] removeItemAtPath:cachePath error:&error]) {
		[DWCache handleError:error];
		return;
	}
}


// Test the cache for the given key and fetch its data if present
// Return nil if not
//
+(NSMutableData*)fetchDataForKey:(NSString*)key {
	
	NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@",cachePath,key];
	BOOL fileFound = NO;
	NSMutableData *cachedData = nil;
	
	//Check if file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		
		if (attributes != nil) {
			NSDate *fileDate = [attributes fileModificationDate];
			
			//Check if elapsed time since creating the file is less than the
			//cache expiry threshold
			if (fabs([fileDate timeIntervalSinceNow]) < CACHE_INTERNAL) {
				fileFound = YES;
			}			
		}
		else {
			[DWCache handleError:error];
		}
	}
	
	if(fileFound)
		cachedData = [[[NSMutableData alloc] initWithContentsOfFile:filePath] autorelease]; 
	
	[filePath release];
	
	return cachedData;		
}


// Create or replace cached data for the given key
//
+(void)setDataForKey:(NSString*)key withData:(NSMutableData*)data {
	
	NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@",cachePath,key];
	
	//Only cache items less than MAX_CACHE_ITEM_SIZE
	if([data length] < MAX_CACHE_ITEM_SIZE) {
		
		//Delete file if it exists
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			
			if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
				[DWCache handleError:error];
				return;
			}
		}
		
		[[NSFileManager defaultManager] createFileAtPath:filePath
												contents:data
											  attributes:nil
		 ];
	}
	
	[filePath release];	
}


// Generic error handler for caching related errors
//
+(void)handleError:(NSError *)error {
	//[GAnalytics logError:error withTitle:@"GCache" withMessage:@"-"];
}

@end
