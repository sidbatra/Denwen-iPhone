//
//  DWItem.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItem.h"



@implementation DWItem

@synthesize data=_data,attachment=_attachment,
	place=_place,user=_user,urls = _urls,fromFollowedPlace=_fromFollowedPlace;


#pragma mark -
#pragma mark Class Lifecycle methods


// Init the class along with its member variables 
//
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_fromFollowedPlace = NO;
	}
	
	return self;  
}



#pragma mark -
#pragma mark View Helper Methods


// Returns whether the item has an attachment
//
- (BOOL)hasAttachment {
	return self.attachment != nil;
}


// Returns Created Time Ago in words
//
- (NSString *)createdTimeAgoInWords {
	
	NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:_createdAtTimestamp];
    NSDate *todayDate = [NSDate date];
    NSInteger ti = [todayDate timeIntervalSinceDate:createdDate];
    	
	if (ti < 60) {
		if (ti <= 1) 
			return [[[NSString alloc] initWithString:@"1 second ago"] autorelease];
		
        return [[[NSString alloc] initWithFormat:@"%d seconds ago", ti] autorelease];
    } 
	else if (ti < 3600) {
        int diff = round(ti / 60);
		if (diff == 1)
			return [[[NSString alloc] initWithString:@"1 minute ago"] autorelease];	
        return [[[NSString alloc] initWithFormat:@"%d minutes ago", diff] autorelease];
    } 
	else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
		if (diff == 1) 
			return [[[NSString alloc] initWithString:@"1 hour ago"] autorelease];
        return [[[NSString alloc] initWithFormat:@"%d hours ago", diff] autorelease];
    } 
	else {
		NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
		[outputFormatter setDateFormat:@"d MMM"];
		NSString *outputString = [[NSString alloc] initWithString:[outputFormatter stringFromDate:createdDate]];
		[outputFormatter release];
		
		return [outputString autorelease];
    }
}



#pragma mark -
#pragma mark Server interaction methods


// Populate the instance with JSON information parsed into
// a NSDictionary object
//
- (void)populate:(NSDictionary*) result {
	[super populate:result];

	_databaseID = [[result objectForKey:@"id"] integerValue];
	_createdAtTimestamp = [[result objectForKey:CREATED_AT_JSON_KEY] doubleValue];	
	
	self.data = [result objectForKey:CONDENSED_DATA_JSON_KEY];
	
	if ([result objectForKey:ATTACHMENT_JSON_KEY]) {
		DWAttachment *tempAttachment = [[DWAttachment alloc] init];
		self.attachment = tempAttachment;
		[tempAttachment release];
		
		[self.attachment populate:[result objectForKey:ATTACHMENT_JSON_KEY]];
	}
	
	/* Create or fetch the place from the memory pool*/
	NSDictionary *placeJSON = [result objectForKey:PLACE_JSON_KEY];
	_place = (DWPlace*)[DWMemoryPool getOrSetObject:placeJSON atRow:kMPPlacesIndex];
	
	/* Create or fetch the user from the memory pool*/
	NSDictionary *userJSON = [result objectForKey:USER_JSON_KEY];
	_user = (DWUser*)[DWMemoryPool getOrSetObject:userJSON atRow:kMPUsersIndex];
	
		
	NSArray *temp = [result objectForKey:URLS_JSON_KEY];
	if ([temp count])
		self.urls = temp;
}


// Override the update method to check for changes to the place and user object
//
- (void)update:(NSDictionary*)objectJSON {

	float interval = -[self.updatedAt timeIntervalSinceNow];
	
	if(interval > kMPObjectUpdateInterval) {
		[_place update:[objectJSON objectForKey:PLACE_JSON_KEY]];
		[_user update:[objectJSON objectForKey:USER_JSON_KEY]];
				
		if([self hasAttachment])
			[_attachment update:[objectJSON objectForKey:ATTACHMENT_JSON_KEY]];
		
		[self refreshUpdatedAt];
	}
		 
}


// Start the download for all remote preview images belonging to the current item
// that have not been downloaded yet
//
- (void)startRemoteImagesDownload {
	if (self.attachment)
		[self.attachment startPreviewDownload];
	if(_place)
		[_place	startSmallPreviewDownload];
	if(_user)
		[_user startSmallPreviewDownload];
}



#pragma mark -
#pragma mark Memory Management


// Free attachment preview image
//
- (void)freeMemory {
	[self.attachment freeMemory];
}


// dealloc cleanup
// 
- (void)dealloc {
	
	//NSLog(@"item being removed - %d",_databaseID);
		
	self.data = nil;
	self.urls = nil;
	
	self.attachment = nil;
	
	if(_place)
		[DWMemoryPool removeObject:_place atRow:kMPPlacesIndex];
	
	if(_user)
		[DWMemoryPool removeObject:_user atRow:kMPUsersIndex];
	
	[super dealloc];
}

@end
